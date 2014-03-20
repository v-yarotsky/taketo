module Taketo
  module Constructs

    class Config < BaseConstruct
      accepts_node_types :group, :project, :server, :shared_server_config

      attr_accessor :default_destination

      def initialize(*args)
        super(nil)
        @shared_server_configs = {}
      end

      def add_shared_server_config(name, server_config)
        if @shared_server_configs.key?(name)
          raise ::Taketo::DuplicateSharedServerConfigError, name
        end
        @shared_server_configs.store(name, server_config)
      end

      def shared_server_config(name)
        @shared_server_configs.fetch(name)
      rescue KeyError
        raise ::Taketo::SharedServerConfigNotFoundError, name
      end
    end

  end
end

