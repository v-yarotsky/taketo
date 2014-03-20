require 'forwardable'

module Taketo
  module Constructs

    class Server < BaseConstruct
      extend Forwardable

      attr_accessor :config, :global_alias
      # TODO rename to included_shared_server_configs
      attr_reader :shared_server_configs

      def_delegators :@config, :environment_variables,
                               :ssh_command,
                               :host,
                               :port,
                               :username,
                               :default_location,
                               :default_command,
                               :identity_file,
                               :commands

      def initialize(name)
        super(name)
        @config = ::Taketo::Support::ServerConfig.new
        @shared_server_configs = []
      end

      def global_alias=(value)
        @global_alias = value.to_s
      end

      def include_shared_server_config(server_config)
        @shared_server_configs << server_config
      end
    end

  end
end

