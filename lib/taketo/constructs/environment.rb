require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Environment < BaseConstruct
      has_nodes :servers, :server

      attr_accessor :project

      def initialize(name)
        super(name)
      end

      def project_name
        @project.name if defined? @project
      end

      def append_server(server)
        server.environment = self
        super
      end
    end
  end
end

