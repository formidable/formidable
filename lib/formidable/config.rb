require "yaml"

module Formidable
  class Config
    class << self

      attr_reader :api_key, :track_values

      def load(config_file)
        begin
          config = YAML::load_file(config_file)
          env_config = config[app_env] || {}
          @api_key = env_config["api-key"] || config["api-key"]
          @track_values = env_config["track-values"]
          @track_values = config["track-values"] if @track_values.nil?
          @track_values = true if @track_values.nil?
        rescue Exception => e
          raise "Configuration error: #{e.message}"
        end
      end

      def app_env
        ENV["RACK_ENV"] || ENV["RAILS_ENV"]|| "development"
      end

    end
  end
end
