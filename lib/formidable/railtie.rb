require "formidable"
require "rails"

module Formidable
  class Railtie < Rails::Railtie

    initializer "formidable.middleware" do |app|
      Formidable::Config.load(File.join(Rails.root, "/#{CONFIG_PATH}"))
      app.config.filter_parameters += [:formidable]
    end
  end
end
