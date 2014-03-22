module Taketo
  module Constructs

    class Config < BaseConstruct
      accepts_node_types :group, :project, :server, :shared_server_config

      attr_accessor :default_destination

      attr_reader :shared_server_configs # just for dsl reopening

      def initialize(*args)
        super(nil)
        @shared_server_configs = {}
        @default_server_config.merge!(
          :ssh_command => :ssh,
          :default_command => "bash"
        )
      end

      def add_shared_server_config(name, server_config_proc)
        if @shared_server_configs.key?(name)
          raise DuplicateSharedServerConfigError, name
        end
        @shared_server_configs.store(name, server_config_proc)
      end

      def shared_server_config(name)
        @shared_server_configs.fetch(name)
      rescue KeyError
        raise SharedServerConfigNotFoundError, name
      end
    end

  end
end

