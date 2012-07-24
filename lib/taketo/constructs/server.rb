require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  class CommandNotFoundError < StandardError; end

  module Constructs
    class Server < BaseConstruct
      attr_reader :environment_variables
      attr_accessor :host, :port, :username, :default_location, :environment, :global_alias
      
      has_nodes :commands, :command

      def initialize(name)
        super
        @environment_variables = {}
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end

      def environment=(environment)
        env(:RAILS_ENV => environment.name.to_s)
        @environment = environment
      end
    end
  end
end

