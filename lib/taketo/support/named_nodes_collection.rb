require 'forwardable'
require 'taketo/support'

module Taketo
  module Support
    class NamedNodesCollection
      include Enumerable
      extend Forwardable

      def_delegators :@nodes, :each, :length, :size, :empty?, :first, :last

      def initialize(nodes = [])
        @nodes = nodes
      end

      def push(node)
        @nodes << node unless find_by_name(node.name)
      end
      alias :<< :push

      def [](index)
        if index.is_a?(Symbol)
          node = find_by_name(index) or raise KeyError, "Element with name #{index} not found"
          return node
        end
        @nodes[index] or raise KeyError, "Element ##{index} not found"
      end

      def find_by_name(name)
        @nodes.detect { |n| n.name == name }
      end
    end
  end
end

