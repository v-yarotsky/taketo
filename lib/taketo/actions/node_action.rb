require 'taketo/node_resolver'

module Taketo
  module Actions

    module NodeAction
      def resolver
        @resolver ||= NodeResolver.new(config, destination_path)
      end
    end

  end
end


