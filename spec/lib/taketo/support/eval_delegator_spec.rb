require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/support/eval_delegator'

class EvalDelegatorContext
  include Taketo::Support::EvalDelegator
  
  def foo
  end
end

describe Taketo::Support::EvalDelegator do
  describe "#evaluate" do
    it "should execute methods on context if it responds" do
      expect do
        EvalDelegatorContext.new.evaluate { foo }
      end.not_to raise_error
    end

    it "should delegate unknown methods to calling context" do
      class << self
        define_method(:bar) {}
      end

      expect do
        EvalDelegatorContext.new.evaluate { bar }
      end.not_to raise_error
    end

    it "should pass local variables through the scopes" do
      baz = :foo
      expect do
        EvalDelegatorContext.new.evaluate { baz }
      end.not_to raise_error
    end
  end
end

