module Formidable
  class Attempt
    class << self

      def parse(cookies, form, valid)
        hash = Digest::MD5.hexdigest("#{Config::api_key}.#{form}")

        cookie = cookies["formidable"]
        cookie_data = cookie ? Marshal.load(cookie) : {} rescue {}

        cookie_data[hash] ||= 1
        attempt = cookie_data[hash]

        unless valid
          cookie_data[hash] += 1
          save_cookie(cookies, cookie_data)
        else
          cookie_data.delete hash
          if cookie_data.empty?
            cookies.delete "formidable"
          else
            save_cookie(cookies, cookie_data)
          end
        end

        attempt
      end

      private

      def save_cookie(cookies, data)
        cookies["formidable"] = {
          :value => Marshal.dump(data),
          :expires => Time.now + 86400
        }
      end

    end
  end
end
