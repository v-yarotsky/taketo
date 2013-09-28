module Taketo
  module Actions

    class Matches < BaseAction
      def initialize(options)
        super
        @resolver = if options[:list]
          NodeResolvers::GroupResolver
        elsif options[:view]
          NodeResolvers::BaseResolver
        else
          NodeResolvers::ServerResolver
        end.new(config, destination_path)
      end

      def run
        puts Support::DestinationMatcher.new(@resolver.nodes).matches.join(" ")
      end
    end

  end
end
