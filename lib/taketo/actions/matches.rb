require 'taketo/destination_matcher'
require 'taketo/actions/base_action'
require 'taketo/group_resolver'
require 'taketo/node_resolver'
require 'taketo/server_resolver'

module Taketo
  module Actions

    class Matches < BaseAction
      def initialize(options)
        super
        @resolver = if options[:list]
          GroupResolver
        elsif options[:view]
          NodeResolver
        else
          ServerResolver
        end.new(config, destination_path)
      end

      def run
        puts DestinationMatcher.new(@resolver.nodes).matches.join(" ")
      end
    end

  end
end
