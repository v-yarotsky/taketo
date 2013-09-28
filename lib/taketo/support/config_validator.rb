module Taketo
  module Support

    class ConfigValidator
      def initialize(traverser)
        @traverser = traverser
      end

      def validate!
        @traverser.visit_depth_first(ConfigVisitors::ValidatorVisitor.new)
      end
    end

  end
end

