require 'forwardable'

module Taketo
  module Support
    class NamedNodesCollection
      include Enumerable
      extend Forwardable

      def_delegators :@nodes, :each, :<<, :push, :length, :size

      def initialize
        @nodes = []
      end

      def [](index)
        if index.is_a?(Symbol)
          node = @nodes.detect { |n| n.name == index } or raise KeyError, "Element with name #{index} not found"
          return node
        end
        @nodes[index] or raise KeyError, "Element ##{index} not found"
      end
    end
  end
end

