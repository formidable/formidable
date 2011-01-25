module Formidable
  module Model
    class << self

      def included(base)
        base.class_eval do

          base.send :alias_method, :original_valid?, :valid?

          def valid?(*args)
            valid = original_valid?(*args)
            return valid unless @formidable

            model_name = self.class.name.underscore

            if valid
              errors = {}
            else
              error_fix = {}
              self.errors.each do |k,v|
                error_fix[k] ||= []
                error_fix[k] << v
              end
              errors = {"#{model_name}" => error_fix}
            end

            request = Thread.current[:formidable_request]
            values = request ? request.params : {"#{model_name}" => self.attributes}

            data = {
              :form => @formidable[:form],
              :errors => errors,
              :values => values,
              :prefix => model_name
            }

            Formidable.track(data)

            valid
          end # valid?

          def make_formidable(form)
            @formidable = {:form => form}
            self
          end # make_formidable
        end
      end

    end
  end
end
