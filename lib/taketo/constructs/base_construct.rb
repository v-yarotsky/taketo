require 'taketo/support'

module Taketo
  class NodesNotDefinedError < StandardError; end

  module Constructs
    class BaseConstruct
      attr_reader :name

      ##
      # Adds nodes collections to the construct
      #
      # Example:
      #
      # class Bar < BaseConstruct
      #   has_nodes :foos, :foo
      # end
      #
      # bar = Bar.new
      # bar.foos                                  # => foos collection
      # bar.append_foo(foo)                       # adds node the collection
      # bar.find_foo(:foo_name)                   # find foo in foos collection by name
      #
      def self.has_nodes(name_plural, name_singular)
        self.node_types << name_plural
        includable = Module.new do
          define_method "append_#{name_singular}" do |object|
            nodes(name_plural) << object
          end

          define_method "find_#{name_singular}" do |name|
            nodes(name_plural).find_by_name(name)
          end

          define_method name_plural do
            nodes(name_plural)
          end

          define_method "has_#{name_plural}?" do
            nodes(name_plural).any?
          end
        end
        self.send(:include, includable)
      end

      def self.node_types
        @node_types ||= []
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

      def has_nodes?(name_plural)
        unless self.class.node_types.include?(name_plural)
          raise NodesNotDefinedError, "#{name_plural} not defined for #{node_type}"
        end
        @nodes.fetch(name_plural) { [] }.any?
      end

      def node_type
        demodulized = self.class.name.gsub(/.*::/, '')
        demodulized.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase.to_sym
      end

    end
  end
end


