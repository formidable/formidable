require "formidable"
require "rails"

module Formidable
  class Railtie < Rails::Railtie

    initializer "formidable.middleware" do |app|
      Formidable::Config.load(File.join(Rails.root, "/config/formidable.yml"))
      app.config.filter_parameters += [:formidable]
    end
  end
end
