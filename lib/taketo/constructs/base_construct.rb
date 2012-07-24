require 'taketo/support'

module Taketo
  class NodesNotDefinedError < StandardError; end

  module Constructs
    class BaseConstruct
      attr_reader :name

      class << self; attr_reader :node_types; end

      def self.has_nodes(name_plural, name_singular)
        @node_types ||= []
        @node_types << name_plural

        define_method "append_#{name_singular}" do |object|
          nodes(name_plural) << object
        end

        define_method "find_#{name_singular}" do |name|
          nodes(name_plural).find_by_name(name)
        end

        define_method name_plural do
          nodes(name_plural)
        end
      end

      def initialize(name)
        @name = name
        @nodes = {}
      end

      def find(singular_node_name, name)
        send("find_#{singular_node_name}", name) or
          if block_given?
            yield
          else
            raise KeyError, "#{singular_node_name} #{name} not found for #{node_type} #{self.name}"
          end
      end

      def nodes(name_plural)
        unless self.class.node_types.include?(name_plural)
          raise NodesNotDefinedError, "#{name_plural} not defined for #{node_type}"
        end
        @nodes[name_plural] ||= Taketo::Support::NamedNodesCollection.new
      end

      def node_type
        demodulized = self.class.name.gsub(/.*::/, '')
        demodulized.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase.to_sym
      end
      
    end
  end
end


