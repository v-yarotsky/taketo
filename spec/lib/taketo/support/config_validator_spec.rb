require 'spec_helper'

module Taketo
  module Support

    describe ConfigValidator do
      let(:traverser) { double(:ConfigTraverser) }

      describe "#validate!" do
        it "visits all nodes with an instance of ConfigValidator::ConfigValidatorVisitor" do
          validator = ConfigValidator.new(traverser)
          traverser.should_receive(:visit_depth_first).with(an_instance_of(ConfigVisitors::ValidatorVisitor))
          validator.validate!
        end
      end
    end

  end
end

