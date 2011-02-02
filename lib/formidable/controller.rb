module Formidable
  module Controller
    class << self

      def included(base)
        base.class_eval do
          before_filter { |c|
            Formidable.clear_filtered_parameters
            Thread.current[:formidable_request] = c.request
            Thread.current[:formidable_cookies] = c.send(:cookies)
          }
        end
      end

    end
  end
end
