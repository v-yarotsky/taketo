require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/base_construct'

include Taketo

describe "BaseConstruct" do
  class TestConstruct < Constructs::BaseConstruct
    attr_reader :foos

    def initialize(name, foos)
      super(name)
      @foos = foos
    end

    def find_foo(name)
      @foos[name]
    end
  end

  let(:foos) { mock(:NamedNodesCollection) }
  let(:construct) { TestConstruct.new(:construct, foos) }

  describe "#find" do
    context "if there is such node" do
      it "should return node object with corresponding name" do
        foos.should_receive(:[]).with(:bar).and_return(:qux)
        construct.find(:foo, :bar).should == :qux
      end
    end

    context "if there is no such command" do
      before(:each) { foos.should_receive(:[]).and_return(nil) }

      it "should yield if block given" do
        expect { |b| construct.find(:foo, :bar, &b) }.to yield_control
      end

      it "should raise KeyError if no block given" do
        expect { construct.find(:foo, :bar) }.to raise_error(KeyError)
      end
    end
  end
end


