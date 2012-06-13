require 'taketo/support/named_nodes_collection'

module Taketo
  module Constructs
    class Environment
      attr_reader :name, :servers

      def initialize(name)
        @name = name
        @servers = Taketo::Support::NamedNodesCollection.new
      end

      def append_server(server)
        server.environment = self
        @servers << server
      end
    end
  end
end

