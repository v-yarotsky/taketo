require 'taketo/constructs/base_construct'
require 'taketo/constructs/command'
require 'taketo/support'

module Taketo
  module Constructs
    class Server < BaseConstruct
      attr_reader :environment_variables
      attr_accessor :host, :port, :username, :default_location, :default_command, :environment, :global_alias, :identity_file

      has_nodes :commands, :command

      def initialize(name)
        super
        @environment_variables = {}
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end

      def parent=(environment)
        env(:RAILS_ENV => environment.name.to_s)
        @environment = environment
        super
      end

      def default_command
        if defined? @default_command
          find_command(@default_command) || Command.explicit_command(@default_command)
        else
          Command.default
        end
      end
    end
  end
end

