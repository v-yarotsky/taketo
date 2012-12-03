require 'taketo/config_visitor'
require 'taketo/config_traverser'

module Taketo
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end

  class DestinationResolver
    def initialize(config, path)
      @config = config
      if String(path).empty? && !String(config.default_destination).empty?
        path = config.default_destination
      end
      @path = path
      @traverser = ConfigTraverser.new(@config)
    end

    def servers
      @servers ||= begin
        collector = SimpleCollector(Taketo::Constructs::Server).new
        @traverser.visit_depth_first(collector)
        collector.result
      end
    end

    def resolve
      resolve_by_global_alias || resolve_by_path
    end

    def resolve_by_global_alias
      servers.select(&:global_alias).detect { |s| s.global_alias == @path.to_sym }
    end

    def resolve_by_path
      matching_servers = servers.select { |s| s.path =~ /^#@path/ }
      disambiguate(matching_servers)
    end

    def get_node
      matching_nodes = nodes.select { |n| n.path == @path }
      disambiguate(matching_nodes)
    end

    def nodes
      @nodes ||= begin
        collector = SimpleCollector(Taketo::Constructs::BaseConstruct).new
        @traverser.visit_depth_first(collector)
        collector.result
      end
    end

    def disambiguate(results)
      case results.length
      when 0
        raise NonExistentDestinationError, "Can't find server for path #@path"
      when 1
        results.first
      else
        raise AmbiguousDestinationError,
          "There are multiple possible destinations: #{results.map(&:path).join(", ")}"
      end
    end
  end
end

