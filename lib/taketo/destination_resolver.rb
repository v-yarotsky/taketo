module Taketo
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end

  class DestinationResolver
    class Path
      PATH = [[:project, :projects], [:environment, :environments], [:server, :servers]].freeze

      class PathNode < Struct.new(:singular, :plural, :name); end

      def initialize(names)
        names = names.split(":").map(&:to_sym)
        @path = PATH.each_with_index.map { |n, i| PathNode.new(*n, names[i]) }
      end

      def specified
        @path.reject { |n| n.name.nil? }
      end

      def unspecified
        @path - specified
      end
    end

    def initialize(config, path)
      @config = config
      if String(path).empty? && !String(config.default_destination).empty?
        path = config.default_destination
      end
      @path = Path.new(path)
    end

    def resolve
      node = get_node
      get_only_server(node)
    end

    def get_node(node = @config, remaining_path = @path.specified)
      handling_failure do
        return node if remaining_path.empty?
        next_in_path = remaining_path.shift
        node = node.find(next_in_path.singular, next_in_path.name)
        get_node(node, remaining_path)
      end
    end

    private

    def get_only_server(node, remaining_path = @path.unspecified)
      return node if remaining_path.empty?
      next_in_path = remaining_path.shift
      nested_nodes = node.nodes(next_in_path.plural)
      if nested_nodes.one?
        node = nested_nodes.first
        get_only_server(node, remaining_path)
      else
        raise AmbiguousDestinationError, "There are multiple #{next_in_path.plural} for #{node.node_type} #{node.name}: #{nested_nodes.map(&:name).join(", ")}"
      end
    end

    def handling_failure(message = nil)
      yield
    rescue KeyError, NonExistentDestinationError
      raise NonExistentDestinationError, message || $!
    end
  end
end

