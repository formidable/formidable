require "base64"
require "json"

module Formidable
  class Timer
    class << self

      def parse(timing_data)
        js_data = JSON.parse(Base64.decode64(timing_data)) rescue nil
        if js_data
          return js_data["total_time"], js_data["times"]
        end
        return nil, {}
      end

    end
  end
end
