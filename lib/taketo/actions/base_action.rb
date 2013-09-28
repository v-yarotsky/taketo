module Taketo
  module Actions

    class BaseAction
      attr_reader :options, :destination_path

      def initialize(options)
        @options          = options
        @destination_path = options[:destination_path]
      end

      def config
        @config ||= begin
          config_file = options[:config]

          DSL.new.configure(config_file).tap do |config|
            traverser = Support::ConfigTraverser.new(config)
            Support::ConfigValidator.new(traverser).validate!
          end
        end
      end
    end

  end
end

