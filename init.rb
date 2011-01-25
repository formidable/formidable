require "getformidable"

begin
  Formidable::Config.load(File.join(Rails.root, "/#{Formidable::CONFIG_PATH}"))
rescue Exception => e
  # do nothing
end
