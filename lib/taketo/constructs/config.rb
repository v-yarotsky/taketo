require 'taketo/support/named_nodes_collection'

module Taketo
  module Constructs
    class Config
      attr_reader :projects

      def initialize
        @projects = Taketo::Support::NamedNodesCollection.new
      end

      def append_project(project)
        @projects << project
      end
    end
  end
end

