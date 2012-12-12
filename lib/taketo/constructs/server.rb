require 'taketo/constructs/base_construct'
require 'taketo/constructs/command'
require 'taketo/support'

module Taketo
  module Constructs
    class Server < BaseConstruct
      attr_reader :environment_variables
      attr_accessor :host, :port, :username, :default_location, :default_command, :global_alias, :identity_file

      has_nodes :commands, :command

      def initialize(name)
        super
        @environment_variables = {}
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end

      def parent=(parent)
        super
        env(:RAILS_ENV => parent.name.to_s) if parent.is_a?(Environment)
      end

      def global_alias=(alias_name)
        @global_alias = alias_name.to_s
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

