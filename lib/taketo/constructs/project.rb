module Taketo
  module Constructs
    class Project
      attr_reader :name, :environments

      def initialize(name)
        @name = name
        @environments = {}
      end

      def append_environment(environment)
        @environments[environment.name] = environment
      end
    end
  end
end

