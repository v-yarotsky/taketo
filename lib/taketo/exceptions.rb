module Taketo
  class ConfigError < StandardError; end
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end
  class NodesNotDefinedError < StandardError; end
  class CommandNotFoundError < StandardError; end
  class DSLScopeError  < StandardError; end
  class DSLConfigError < StandardError; end

  unless defined? KeyError
    class KeyError < StandardError; end
  end
end

