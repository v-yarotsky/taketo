require 'taketo/config_visitor'
require 'taketo/config_traverser'

module Taketo

  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end

  class NodeResolver
    def initialize(config, path)
      @config = config
      if String(path).empty? && !String(config.default_destination).empty?
        path = config.default_destination
      end
      @path = path
      @traverser = ConfigTraverser.new(@config)
    end

    def resolve
      resolve_by_path
    end

    def resolve_by_path
      matching_nodes = nodes.select { |n| n.path == @path }
      disambiguate(matching_nodes)
    end

    def nodes
      @nodes ||= begin
        collector = SimpleCollector(Taketo::Constructs::BaseConstruct).new
        @traverser.visit_depth_first(collector)
        collector.result.reject { |n| Taketo::Constructs::Command === n }
      end
    end

    def disambiguate(results)
      case results.length
      when 0
        raise NonExistentDestinationError, "Can't find such destination: #@path"
      when 1
        results.first
      else
        exact_match = results.detect { |n| n.path == @path }
        exact_match or raise AmbiguousDestinationError,
          "There are multiple possible destinations: #{results.map(&:path).join(", ")}"
      end
    end
  end

end


