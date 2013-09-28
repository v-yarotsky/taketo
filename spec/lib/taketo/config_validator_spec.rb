require 'spec_helper'
require 'taketo/config_validator'

module Taketo

  describe ConfigValidator do
    let(:traverser) { stub(:ConfigTraverser) }

    describe "#validate!" do
      it "visits all nodes with an instance of ConfigValidator::ConfigValidatorVisitor" do
        validator = ConfigValidator.new(traverser)
        traverser.should_receive(:visit_depth_first).with(an_instance_of(ConfigVisitors::ValidatorVisitor))
        validator.validate!
      end
    end
  end

end

