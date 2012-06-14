module Taketo
  module Constructs
    class Server
      attr_reader :name, :environment_variables
      attr_accessor :host, :port, :username, :default_location, :environment
      
      def initialize(name)
        @name = name
        @environment_variables = {}
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end
    end
  end
end

