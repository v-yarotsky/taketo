module Taketo
  class ConfigTraverser
    LEVELS = { :config => 1, :project => 2, :environment => 3, :server => 4, :command => 5 }.freeze
    PLURALS = { :config => :configs, :project => :projects, :environment => :environments, :server => :servers, :command => :commands }.freeze

    def initialize(root)
      @root = root
    end

    def visit_depth_first(visitor)
      queue = [@root]

      while queue.any?
        node = queue.pop
        node.accept(visitor)

        next_level_node_type = LEVELS.respond_to?(:key) ? LEVELS.key(LEVELS[node.node_type] + 1) : LEVELS.index(LEVELS[node.node_type] + 1)
        if next_level_node_type && node.has_nodes?(PLURALS[next_level_node_type])
          node.nodes(PLURALS[next_level_node_type]).each { |n| queue.push(n) }
        end
      end
    end

    def get_all_of_level(level)
      queue = [@root]
      result = []

      while queue.any?
        node = queue.shift
        if LEVELS[node.node_type] == LEVELS[level]
          result.push node
        else
          next_level_node_type = LEVELS.respond_to?(:key) ? LEVELS.key(LEVELS[node.node_type] + 1) : LEVELS.index(LEVELS[node.node_type] + 1)
          if node.has_nodes?(PLURALS[next_level_node_type]) && LEVELS[node.node_type] < LEVELS[level]
            node.nodes(PLURALS[next_level_node_type]).each { |n| queue.push(n) }
          end
        end
      end
      result
    end
  end
end

