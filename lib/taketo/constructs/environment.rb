module Taketo
  module Constructs

    class Environment < BaseConstruct
      accepts_node_types :group, :server

      def initialize(name)
        super(name)
        @default_server_config = add_rails_env(@default_server_config)
      end

      def default_server_config=(server_config)
        super(add_rails_env(server_config))
      end

      def add_rails_env(server_config)
        ::Taketo::Support::ServerConfig.new(:environment_variables => { :RAILS_ENV => name.to_s }).merge(server_config)
      end
      private :add_rails_env
    end

  end
end

