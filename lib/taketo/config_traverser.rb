module Taketo
  class ConfigTraverser
    LEVELS = { :config => 1, :project => 2, :environment => 3, :server => 4, :command => 5 }.freeze
    PLURALS = { :config => :configs, :project => :projects, :environment => :environments, :server => :servers, :command => :commands }.freeze

    def initialize(config)
      @config = config
    end

    def get_all_of_level(level)
      queue = [@config]
      result = []

      while queue.any?
        node = queue.shift
        if LEVELS[node.node_type] == LEVELS[level]
          result.push node
        else
          next_level_node_type = LEVELS.key(LEVELS[node.node_type] + 1)
          if node.has_nodes?(PLURALS[next_level_node_type]) && LEVELS[node.node_type] < LEVELS[level]
            node.nodes(PLURALS[next_level_node_type]).each { |n| queue.push(n) }
          end
        end
      end
      result
    end
  end
end

