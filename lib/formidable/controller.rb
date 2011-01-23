module Formidable
  module Controller
    class << self

      def included(base)
        base.class_eval do
          before_filter { |c|
            Formidable.clear_filtered_parameters
            Thread.current[:formidable_request] = request
          }
        end
      end

    end
  end
end
