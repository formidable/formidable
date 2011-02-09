module Formidable
  class Commands
    class << self

      def run(args)

        if args[0] == "install" and api_key = args[1]

          config = <<CONFIG
# Leave api_key blank to disable Formidable for a specific environment.

development:
  api_key: #{api_key}

production:
  api_key: #{api_key}
CONFIG

          Dir.mkdir("config") unless File.exists?("config")
          File.open(CONFIG_PATH, "w") {|f| f.write(config)}

          puts "Created config file at #{CONFIG_PATH}."
        elsif args[0] == "test"
          begin
            Config.load_file(CONFIG_PATH)
            Config.thread = false

            Formidable.track(
              :form => "Test",
              :errors => {:email => "is invalid"},
              :values => {:email => "test@formidable"},
              :attempt => 1,
              :total_time => 10.1,
              :times => {:username => 2.4, :email => 5.6}
            )

            Formidable.track(:form => "Test", :attempt => 2)

            Formidable.track(
              :form => "Test",
              :errors => {:email => "is invalid", :username => "is already taken"},
              :attempt => 1
            )

            Formidable.track(:form => "Test", :attempt => 2)

            Formidable.track(:form => "Test", :attempt => 1)

            Formidable.track(:form => "Test", :attempt => 1)

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
