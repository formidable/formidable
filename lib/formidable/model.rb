module Formidable
  module Model
    class << self

      def included(base)
        base.class_eval do

          def make_formidable(form)
            valid = self.class.instance_method(:valid?)
            @formidable = {:form => form, :valid => valid}

            def valid?
              valid = @formidable[:valid].bind(self).call

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
            end

            self
          end

        end
      end

    end

  end
end
