require 'taketo/server_resolver'

module Taketo
  module Actions

    module ServerAction
      def resolver
        @resolver ||= ServerResolver.new(config, destination_path)
      end
    end

  end
end

