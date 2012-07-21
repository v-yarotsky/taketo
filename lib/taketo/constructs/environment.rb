require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Environment < BaseConstruct
      attr_reader :servers

      def initialize(name)
        super
        @servers = Taketo::Support::NamedNodesCollection.new
      end

      def append_server(server)
        server.environment = self
        @servers << server
      end

      def find_server(name)
        @servers.find_by_name(name)
      end
    end
  end
end

