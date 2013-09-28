require 'taketo/destination_matcher'
require 'taketo/actions/base_action'
require 'taketo/node_resolvers'

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
        puts DestinationMatcher.new(@resolver.nodes).matches.join(" ")
      end
    end

  end
end
