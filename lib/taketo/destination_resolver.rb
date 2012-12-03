module Taketo
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end

  class DestinationResolver
    class Path
      PATH = [[:project, :projects], [:environment, :environments], [:server, :servers]].freeze

      class PathNode < Struct.new(:name, :singular, :plural); end

      def initialize(names)
        names = names.split(":").map(&:to_sym)
        @path = PATH.each_with_index.map { |n, i| PathNode.new(names[i], *n) }
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
      @path_str = path.dup
      @path = Path.new(path)
    end

    def resolve
      resolve_by_global_alias || resolve_by_path
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

    def resolve_by_global_alias
      aliases_and_servers = Hash[servers_with_aliases]
      aliases_and_servers[@path_str.to_sym] unless String(@path_str).empty?
    end

    def resolve_by_path
      node = get_node
      get_only_server(node)
    end

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
      raise NonExistentDestinationError, message || $!.message
    end

    class Servers < ConfigVisitor
      attr_reader :servers

      def initialize
        @servers = []
      end

      visit Server do |s|
        @servers << s
      end

      def servers_with_aliases
        @servers.select(&:global_alias)
      end
    end

    def servers_with_aliases
      @config.nodes(:projects).map { |p| p.nodes(:environments).map { |e| e.nodes(:servers).reject { |s| s.global_alias.nil? }.map { |s| [s.global_alias, s] } } }.flatten(2)
    end
  end
end

