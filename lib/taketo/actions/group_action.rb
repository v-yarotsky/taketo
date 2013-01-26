require 'taketo/group_resolver'

module Taketo
  module Actions

    module GroupAction
      def resolver
        @resolver ||= GroupResolver.new(config, destination_path)
      end
    end

  end
end


