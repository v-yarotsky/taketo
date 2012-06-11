module Taketo
  module Support

    ##
    # This module allows to use external
    # methods in block used by instance_eval,
    # that it effectively mimics real closure
    #
    module EvalDelegator
      def evaluate(&block)
        @external_self = eval "self", block.binding
        self.instance_eval(&block)
      end

      def method_missing(method_name, *args, &block)
        if @external_self.respond_to?(method_name)
          @external_self.send(method_name, *args, &block)
        else
          super
        end
      end
    end
  end
end

