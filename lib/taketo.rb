module Taketo
  version_file = File.expand_path('../VERSION', File.dirname(__FILE__))
  VERSION = File.read(version_file).freeze
end

require 'taketo/support'
require 'taketo/dsl'
require 'taketo/commands'
require 'taketo/config_traverser'
require 'taketo/config_validator'
require 'taketo/config_printer_visitor'

