require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Environment < BaseConstruct
      has_nodes :servers, :server

      def append_server(server)
        server.environment = self
        nodes(:servers) << server
      end
    end
  end
end

