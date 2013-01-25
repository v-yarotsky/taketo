require 'taketo/destination_matcher'
require 'taketo/actions/base_action'

module Taketo
  module Actions

    class Matches < BaseAction
      def run
        puts DestinationMatcher.new(resolver.servers).matches.join(" ")
      end
    end

  end
end
