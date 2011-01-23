require "net/http"
require "net/https"
require "json"

module Formidable
  class Remote
    class << self

      def send(data)
        uri = URI.parse("https://#{HOST}/track")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        query = "api_key=#{Config.api_key}&version=#{VERSION}"
        resp = http.post("#{uri.path}?#{query}", data.to_json)

        if defined?(Rails)
          Rails.logger.info data.to_json
          Rails.logger.info "Response: #{resp.code}"
        end
      end

    end
  end
end
