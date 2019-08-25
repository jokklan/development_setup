require 'jokklan/development_setup/version'
require 'jokklan/development_setup/railtie' if defined?(Rails)

module Jokklan
  module DevelopmentSetup
    class Error < StandardError; end
    # Your code goes here...
  end
end
