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

  HOST = "dev-api.getformidable.com"
  #HOST = "api.getformidable.com"
  VERSION = 1
  CONFIG_PATH = "config/formidable.yml"

  @@filtered_params = []

  class << self

    def filter_parameters(*params)
      @@filtered_params = @@filtered_params | params.flatten
    end

    def clear_filtered_parameters
      @@filtered_params = []
    end

    def track(*args)
      return unless Config.api_key

      args = args[0] if args.kind_of?(Array)
      raise "Must define a form." unless args[:form]

      occurred_at = Time.now

      errors = args[:errors] || {}
      errors = {:base => errors} if errors.any? and errors.kind_of?(Array)

      # values will be nil if errors and no args[:values]
      # we want this for later
      values = {} unless Config.track_values
      values ||= errors.any? ? args[:values] : {}

      times = args[:times]
      total_time = args[:total_time]
      attempt = args[:attempt]

      # get as much data as we can from the request object
      # don't override anything that was set
      if args[:timing_data]
        tt, t = Timer.parse(args[:timing_data])
        total_time ||= tt
        times ||= t
      end

      request = Thread.current[:formidable_request]
      if request
        filter_parameters(request.env["action_dispatch.parameter_filter"])
        # if values aren't set, get them from request and delete
        values ||= request.params.reject{|k, v| [:utf8, :action, :controller, :authenticity_token, :commit, :formidable].include?(k.to_sym) }
        attempt ||= Attempt.parse(request, args[:form], errors.empty?)

        if timing_data = request.params[:formidable]
          tt, t = Timer.parse(request.params[:formidable])
          total_time ||= tt
          times ||= t
        end
      else
        times ||= {}
      end

      # filter values
      values.delete_if{|k,v| filter?(k)}

      # flatten everything
      flatten(errors, true)
      flatten(values)
      flatten(times)

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
        :occurred_at => occurred_at,
        :errors => errors,
        :values => values,
        :times => times,
        :total_time => total_time,
        :attempt => attempt
      }

      Remote.send(data)
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
        unless v.kind_of?(Hash) #or v.kind_of?(HashWithIndifferentAccess)
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
