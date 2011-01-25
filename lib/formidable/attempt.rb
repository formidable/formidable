module Formidable
  class Attempt
    class << self

      def parse(request, form, valid)
        hash = Digest::MD5.hexdigest("#{Config::api_key}.#{form}")

        cookie = request.cookies["formidable"]
        cookie_data = cookie ? Marshal.load(cookie) : {} rescue {}
        cookie_data[hash] ||= 1
        attempt = cookie_data[hash]

        unless valid
          cookie_data[hash] += 1
          save_cookie(cookie_data, request)
        else
          cookie_data.delete hash
          if cookie_data.empty?
            request.cookie_jar.delete "formidable"
          else
            save_cookie(cookie_data, request)
          end
        end

        attempt
      end

      private

      def save_cookie(data, request)
        request.cookies["formidable"] = {
          :value => Marshal.dump(data),
          :expires => 1.days.from_now
        }
      end

    end
  end
end
