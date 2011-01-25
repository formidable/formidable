require "net/http"
require "net/https"
require "json"

module Formidable
  class Remote
    class << self

      def send(data)
        uri = URI.parse("https://#{HOST}/track")

        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          query = "api_key=#{Config.api_key}&version=#{VERSION}"
          res = http.post("#{uri.path}?#{query}", data.to_json)

          if defined?(Rails)
            Rails.logger.info data.to_json
            Rails.logger.info "Response: #{res.code}"
          end
        rescue
          nil
        end
      end

    end
  end
end
