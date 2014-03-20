require 'delegate'
require 'forwardable'
require 'set'

module Taketo
  module Support

    class ConfigTraverser
      def initialize(root)
        @root = root
      end

      def visit_depth_first(visitor)
        stack = [@root]
        visited = Set.new

        while stack.any?
          node = stack.last
          if visited.include?(node.object_id)
            visitor.after_visit(node)
            stack.pop
          else
            visitor.visit(node)
            visited << node.object_id

            node.nodes.reverse_each do |n|
              stack.push(n)
            end
          end
        end
      end
    end

  end
end

