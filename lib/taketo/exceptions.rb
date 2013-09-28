module Taketo
  class ConfigError < StandardError; end
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end
  class NodesNotDefinedError < StandardError; end
end

