require 'taketo/destination_matcher'
require 'taketo/actions/base_action'
require 'taketo/actions/server_action'
require 'taketo/actions/group_action'
require 'taketo/actions/node_action'

module Taketo
  module Actions

    class Matches < BaseAction
      def initialize(options)
        super
        if options[:list]
          self.extend(GroupAction)
        elsif options[:view]
          self.extend(NodeAction)
        else
          self.extend(ServerAction)
        end
      end

      def run
        puts DestinationMatcher.new(resolver.nodes).matches.join(" ")
      end
    end

  end
end
