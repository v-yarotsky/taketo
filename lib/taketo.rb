module Taketo
  version_file = File.expand_path('../VERSION', File.dirname(__FILE__))
  VERSION = File.read(version_file).freeze

  # Eager requries
  require 'taketo/exceptions'

  # Lazy requires
  autoload :Actions,           'taketo/actions'
  autoload :Commands,          'taketo/commands'
  autoload :ConfigVisitors,    'taketo/config_visitors'
  autoload :Constructs,        'taketo/constructs'
  autoload :ConstructsFactory, 'taketo/constructs_factory'
  autoload :DSL,               'taketo/dsl'
  autoload :NodeResolvers,     'taketo/node_resolvers'
  autoload :Support,           'taketo/support'
end

