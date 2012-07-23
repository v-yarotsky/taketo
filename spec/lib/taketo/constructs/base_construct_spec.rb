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

  describe "#node_type" do
    it "should return demodulized snake-cased class name" do
      construct.node_type.should == :test_construct
    end
  end

  describe "nodes" do
    class TestConstruct2 < Constructs::BaseConstruct
      has_nodes :foos, :foo
    end

    let(:construct) { TestConstruct2.new(:node_name) }

    let(:foo) { stub(:name => :bar) }

    describe ".has_nodes" do
      it "should define add node type to class's node_types" do
        TestConstruct2.node_types.should include(:foos)
      end

      it "should make nodes accessible via added methods" do
        construct.append_foo(foo)
        construct.foos.should include(foo)
        construct.find_foo(:bar).should == foo
      end
    end

    describe "#nodes" do
      it "should return nodes collection by plural name" do
        construct.append_foo(foo)
        construct.nodes(:foos).should include(foo)
      end

      it "should raise NodesNotDefinedError if non-specified node requested" do
        expect { construct.nodes(:bars) }.to raise_error(NodesNotDefinedError, /bars/)
      end
    end
  end
end


