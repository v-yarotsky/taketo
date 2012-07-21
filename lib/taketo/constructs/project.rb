require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Project < BaseConstruct
      attr_reader :environments

      def initialize(name)
        super
        @environments = Taketo::Support::NamedNodesCollection.new
      end

      def append_environment(environment)
        @environments << environment
      end

      def find_environment(name)
        @environments.find_by_name(name)
      end
    end
  end
end

