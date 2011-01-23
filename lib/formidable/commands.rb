module Formidable
  class Commands
    class << self

      def run(args)

        if args[0] == "install" and api_key = args[1]

          config = <<CONFIG
# Leave api-key blank to disable Formidable for a specific environment.

development:
  api-key: #{api_key}

production:
  api-key: #{api_key}
CONFIG

          Dir.mkdir("config") unless File.exists?("config")
          File.open(CONFIG_PATH, "w") {|f| f.write(config)}

          puts "Created config file at #{CONFIG_PATH}."
        elsif args[0] == "test"
          begin
            Formidable::Config.load(CONFIG_PATH)
            Formidable.track(:form => "Test", :errors => {:email => "is invalid"}, :values => {:email => "test@formidable"})
            Formidable.track(:form => "Test")
            Formidable.track(:form => "Test")
            puts "Test successful! Login to http://www.getformidable.com to see it."
          rescue Exception => e
            puts "Test failed:\n  #{e.message}"
          end
        else
          help =<<HELP
Usage:
  formidable install <api-key>
  formidable test
HELP
          puts help
        end

      end

    end
  end
end
