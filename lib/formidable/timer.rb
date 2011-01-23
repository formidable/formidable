module Formidable
  class Timer
    class << self

      def parse(request)
        js_param = request.params[:formidable]
        js_data = js_param ? JSON.parse(ActiveSupport::Base64.decode64(js_param)) : nil rescue nil
        if js_data
          return js_data["total_time"], js_data["times"]
        end

        return nil, {}
      end

    end
  end
end
