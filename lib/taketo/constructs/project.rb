require 'taketo/support/named_nodes_collection'

module Taketo
  module Constructs
    class Project
      attr_reader :name, :environments

      def initialize(name)
        @name = name
        @environments = Taketo::Support::NamedNodesCollection.new
      end

      def append_environment(environment)
        @environments << environment
      end
    end
  end
end

