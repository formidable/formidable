require "yaml"

module Formidable
  class Config
    class << self

      DEFAULTS = {
        :api_key => "",
        :use_ssl => false,
        :track_values => false,
        :thread => true
      }

      attr_accessor :api_key, :use_ssl, :track_values, :thread

      def load_file(config_file)
        begin
          config = YAML::load_file(config_file)
          env_config = config[app_env] || {}
          settings = config.merge(env_config)
          load(settings)
        rescue Exception => e
          raise "Configuration error: #{e.message}"
        end
      end

      def load(settings)
        # symbolize keys
        settings = settings.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

        # ensure we have default settings
        settings = DEFAULTS.merge(settings)

        [:api_key, :use_ssl, :track_values, :thread].each do |setting|
          self.send("#{setting}=", settings[setting])
        end
      end

      private

      def app_env
        ENV["RACK_ENV"] || ENV["RAILS_ENV"]|| "development"
      end

      def get_key(key, default)
        val = @env_config["track-values"]
        val = @config["track-values"] if val.nil?
        val = default if val.nil?
        val
      end

    end
  end
end
