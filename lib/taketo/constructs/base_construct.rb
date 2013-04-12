require 'taketo/support'
require 'taketo/associated_nodes'

module Taketo
  module Constructs

    class BaseConstruct
      include AssociatedNodes

      attr_accessor :parent
      attr_reader :name
      attr_writer :default_server_config

      def initialize(name)
        super
        @name = name
        @default_server_config = proc {}
        @parent = NullConstruct
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

      def parents
        result = []
        p = parent
        while p != NullConstruct
          result << p
          p = p.parent
        end
        result
      end

      def path
        parents.reverse_each.map(&:name).concat([self.name]).reject(&:nil?).join(":")
      end

      def default_server_config
        parent_default_server_config = parent.default_server_config
        own_default_server_config = @default_server_config
        proc { instance_eval(&parent_default_server_config); instance_eval(&own_default_server_config)}
      end

      def qualified_name
        "#{node_type} #{self.name}"
      end
    end

    class NullConstructClass
      def default_server_config; proc {}; end
    end

    NullConstruct = NullConstructClass.new

  end
end


