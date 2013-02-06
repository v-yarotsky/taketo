module Taketo
  class NodesNotDefinedError < StandardError; end

  module AssociatedNodes

    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
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
      def has_nodes(name_plural, name_singular)
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

      def node_types
        @node_types ||= []
      end
    end

    module InstanceMethods
      def initialize(*args)
        @nodes = {}
      end

      def find(singular_node_name, name)
        send("find_#{singular_node_name}", name) or
          if block_given?
            yield
          else
            raise KeyError, "#{singular_node_name} #{name} not found for #{qualified_name}"
          end
      end

      def nodes(name_plural)
        unless self.class.node_types.include?(name_plural)
          raise NodesNotDefinedError, "#{name_plural} not defined for #{qualified_name}"
        end
        @nodes[name_plural] ||= Taketo::Support::NamedNodesCollection.new
      end

      def has_nodes?(name_plural)
        unless self.class.node_types.include?(name_plural)
          raise NodesNotDefinedError, "#{name_plural} not defined for #{qualified_name}"
        end
        @nodes.fetch(name_plural) { [] }.any?
      end

      def has_deeply_nested_nodes?(name_plural)
        has_nodes?(name_plural) || self.class.node_types.any? { |n| nodes(n).any? { |node| node.has_deeply_nested_nodes?(name_plural) } }
      end

      ##
      # Ovverride for better error messages
      def qualified_name
        self.class.name
      end
    end

  end
end

