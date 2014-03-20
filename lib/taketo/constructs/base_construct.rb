module Taketo
  module Constructs

    class BaseConstruct
      include Taketo::Support::ChildrenNodes

      attr_accessor :parent, :default_server_config, :path
      attr_reader :name

      def initialize(name)
        @name = name
        @default_server_config = ::Taketo::Support::ServerConfig.new
        @parent = NullConstruct
        yield self if block_given?
      end

      def node_type
        demodulized = self.class.name.gsub(/.*::/, '')
        demodulized.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase.to_sym
      end

      ##
      # Override in subclasses if needed
      def parent=(parent)
        @parent = parent
      end

      def qualified_name
        "#{node_type} #{name}"
      end
    end

    class NullConstructClass
      def default_server_config; ::Taketo::Support::ServerConfig.new; end
      def qualified_name; ""; end
    end

    NullConstruct = NullConstructClass.new
  end
end


