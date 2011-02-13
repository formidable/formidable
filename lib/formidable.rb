require "formidable/config"
require "formidable/remote"
require "formidable/attempt"
require "formidable/timer"
require "formidable/controller"
require "formidable/view_helpers"
require "formidable/commands"
require "formidable/model"

if defined?(Rails::Railtie)
  require "formidable/railtie"
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send :include, Formidable::Model
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, Formidable::ViewHelpers
end

if defined?(ActionController::Base)
  ActionController::Base.send :include, Formidable::Controller
end

module Formidable

  HOST = "www.getformidable.com"
  VERSION = 1
  CONFIG_PATH = "config/formidable.yml"

  @@filtered_params = []

  class << self

    def track(args)
      return if Config.api_key.empty?

      raise "Must define a form." unless args[:form]

      errors = args[:errors] || {}
      errors = {:base => errors} if errors.any? and errors.kind_of?(Array)

      # values will be nil if errors and no args[:values]
      # we want this for later
      values =
      if Config.track_values and errors.any?
        args[:values]
      else
        {}
      end

      times = args[:times]
      total_time = args[:total_time]
      attempt = args[:attempt]

      if args[:timing_data]
        tt, t = Timer.parse(args[:timing_data])
        total_time ||= tt
        times ||= t
      end

      # get as much data as we can from the request object
      # don't override anything that was set
      request = Thread.current[:formidable_request]
      if request
        # Rails 3
        if request.env["action_dispatch.parameter_filter"]
          filter_parameters(request.env["action_dispatch.parameter_filter"])
        end

        # if values aren't set, get them from request and delete
        values ||= request.params.reject{|k, v| [:utf8, :action, :controller, :authenticity_token, :commit, :formidable].include?(k.to_sym) }

        if timing_data = request.params[:formidable]
          tt, t = Timer.parse(request.params[:formidable])
          total_time ||= tt
          times ||= t
        end
      end

      times ||= {}
      values ||= {}

      cookies = Thread.current[:formidable_cookies]
      if cookies
        attempt ||= Attempt.parse(cookies, args[:form], errors.empty?)
      end

      # filter values
      values.delete_if{|k,v| filter?(k)}

      # flatten everything
      flatten(errors, true)
      flatten(values)
      flatten(times)

      # delete values if no errors for field
      values.delete_if{|k,v| !errors[k] or errors[k].empty?}

      # time to strip the prefix
      prefix = args[:prefix]
      if prefix
        regex = Regexp.new('\A' + prefix.to_s + '\[([^\]]+)\]')
        remove_prefix(errors, regex)
        remove_prefix(values, regex)
        remove_prefix(times, regex)
      end

      data = {
        :form => args[:form],
        :errors => errors,
        :values => values,
        :times => times,
        :total_time => total_time,
        :attempt => attempt
      }

      if Config.thread
        Thread.new do
          Remote.send(data)
        end
        true
      else
        Remote.send(data)
      end
    end

    def configure(args)
      Config.load(args)
    end

    def filter_parameters(*params)
      @@filtered_params = @@filtered_params | params.flatten
    end

    def clear_filtered_parameters
      @@filtered_params = []
    end

    private

    def remove_prefix(data, regex)
      return unless data
      data.dup.each do |k, v|
        key = k.to_s.gsub(regex, '\1')
        data[key] = v
        data.delete(k)
      end
    end

    def filter?(k)
      @@filtered_params.each do |param|
        if Regexp.new(param.to_s).match(k)
          return true
        end
      end
      false
    end

    def flatten(ret, arr=false, name=nil, values=nil)
      values = ret.dup unless values
      values.each do |k, v|
        k = "#{name}[#{k}]" if name
        unless v.kind_of?(Hash)
          if !arr or v.kind_of?(Array)
            ret[k] = v
          else
            ret[k] = [] unless v.kind_of?(Array)
            ret[k] << v
          end
        else
          flatten(ret, arr, k, v)
          ret.delete(k) unless name
        end
      end
      ret
    end

  end
end
