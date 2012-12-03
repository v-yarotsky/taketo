require 'delegate'
require 'forwardable'

module Taketo
  class ConfigTraverser
    def initialize(root)
      @root = root
    end

    def visit_depth_first(visitor)
      path_stack = [@root]

      while path_stack.any?
        node = path_stack.pop
        visitor.visit(node)

        node.class.node_types.each do |node_type|
          node.nodes(node_type).reverse_each do |n|
            path_stack.push(n)
          end
        end
      end
    end
  end
end

