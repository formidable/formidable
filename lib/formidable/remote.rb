require "net/http"
require "net/https"
require "json"

module Formidable
  class Remote
    class << self

      def send(data)
        use_ssl = Config.use_ssl

        protocol = use_ssl ? "https://" : "http://"
        uri = URI.parse("#{protocol}#{HOST}/api/track")

        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = 1

          if use_ssl
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          query = "api_key=#{Config.api_key}&version=#{VERSION}"
          res = http.post("#{uri.path}?#{query}", data.to_json)

          (res.code.to_i == 200)
        rescue
          false
        end
      end

    end
  end
end
