module Taketo
  module Constructs

    class Server < BaseConstruct
      DELEGATED_METHODS = ServerConfig.public_instance_methods - Object.public_instance_methods

      attr_accessor :config

      def initialize(name)
        super(name)
        @config = ServerConfig.new
      end

      def fetch_command(name_or_explicit_command)
        commands.detect { |cmd| cmd.name == name_or_explicit_command } ||
          ServerCommand.explicit_command(name_or_explicit_command)
      end

      def method_missing(method_name, *args, &block)
        if DELEGATED_METHODS.include?(method_name)
          config.public_send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, *)
        DELEGATED_METHODS.include?(method_name)
      end
    end

  end
end

