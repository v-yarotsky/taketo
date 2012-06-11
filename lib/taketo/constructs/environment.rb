module Taketo
  module Constructs
    class Environment
      attr_reader :name, :servers

      def initialize(name)
        @name = name
        @servers = {}
      end

      def append_server(server)
        @servers[server.name] = server
      end
    end
  end
end

