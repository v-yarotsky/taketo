module Taketo
  module Support

    class DestinationMatcher
      def initialize(nodes)
        @nodes = nodes
      end

      def matches
        (path_matches + global_alias_matches).uniq
      end

      private

      def path_matches
        @nodes.map(&:path)
      end

      def global_alias_matches
        @nodes.select { |n| n.respond_to?(:global_alias) }.map(&:global_alias).map(&:to_s).reject(&:empty?)
      end
    end

  end
end

