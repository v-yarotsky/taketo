require 'forwardable'

module Taketo
  module Constructs

    class Server < BaseConstruct
      extend Forwardable

      attr_accessor :config

      def_delegators :@config, :environment_variables,
                               :ssh_command,
                               :host,
                               :port,
                               :username,
                               :default_location,
                               :default_command,
                               :identity_file,
                               :global_alias,
                               :commands

      def initialize(name)
        super(name)
        @config = ::Taketo::Support::ServerConfig.new
      end

      def fetch_command(name_or_explicit_command)
        commands.detect { |cmd| cmd.name == name_or_explicit_command } ||
          ::Taketo::Support::Command.explicit_command(name_or_explicit_command)
      end
    end

  end
end

