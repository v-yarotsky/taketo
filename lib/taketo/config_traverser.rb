require 'delegate'
require 'forwardable'

module Taketo
  class ConfigTraverser
    LEVELS = { :config => 1, :project => 2, :environment => 3, :server => 4, :command => 5 }.freeze
    PLURALS = { :config => :configs, :project => :projects, :environment => :environments, :server => :servers, :command => :commands }.freeze

    class NodeWithPath < SimpleDelegator
      extend Forwardable
      def_delegators :__getobj__, :class, :ancestors # avoid ancestry tree troubles

      def initialize(node, path_string)
        super(node)
        @path = path_string
      end

      def path
        @path.dup
      end
    end

    def initialize(root)
      @root = root
    end

    def visit_depth_first(visitor)
      parents = []
      path_stack = [wrap_node_with_path(parents, @root)]

      while path_stack.any?
        node = path_stack.pop
        visitor.visit(node)

        next_level_node_type = LEVELS.respond_to?(:key) ? LEVELS.key(LEVELS[node.node_type] + 1) : LEVELS.index(LEVELS[node.node_type] + 1)
        if next_level_node_type && node.has_nodes?(PLURALS[next_level_node_type])
          parents << node
          node.nodes(PLURALS[next_level_node_type]).each do |n|
            n = wrap_node_with_path(parents, n)
            path_stack.push(n) 
          end
        end
      end
    end

    private

    def wrap_node_with_path(parents, node)
      NodeWithPath.new(node, path(parents, node))
    end

    def path(parents, node)
      parents.map(&:name).reject(&:nil?).concat([node.name]).join(":")
    end
  end
end

