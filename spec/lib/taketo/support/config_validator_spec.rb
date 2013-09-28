require 'spec_helper'

module Taketo::Support

  describe ConfigValidator do
    let(:traverser) { stub(:ConfigTraverser) }

    describe "#validate!" do
      it "visits all nodes with an instance of ConfigValidator::ConfigValidatorVisitor" do
        validator = ConfigValidator.new(traverser)
        traverser.should_receive(:visit_depth_first).with(an_instance_of(Taketo::ConfigVisitors::ValidatorVisitor))
        validator.validate!
      end
    end
  end

end

