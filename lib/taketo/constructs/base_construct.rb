require 'taketo/support'
require 'taketo/associated_nodes'

module Taketo
  module Constructs
    class BaseConstruct

      include AssociatedNodes
      attr_reader :name, :default_server_config

      def initialize(name)
        super
        @name = name
        @default_server_config = proc {}
      end

      def node_type
        demodulized = self.class.name.gsub(/.*::/, '')
        demodulized.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase.to_sym
      end

      ##
      # Override in subclasses if needed
      def parent=(parent)
        @default_server_config = parent.default_server_config
      end

      def default_server_config=(config)
        default = @default_server_config
        @default_server_config = proc { instance_eval(&default); instance_eval(&config) }
      end

      def qualified_name
        "#{node_type} #{self.name}"
      end

    end
  end
end


