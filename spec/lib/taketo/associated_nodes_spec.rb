require 'spec_helper'
require 'taketo/associated_nodes'

include Taketo

class TestAssociatedNodes
  include AssociatedNodes

  has_nodes :foos, :foo
end

describe "AssociatedNodes" do
  subject(:construct) { TestAssociatedNodes.new(:my_node) }
  let(:foo) { stub(:FooNode, :name => :bar) }

  describe ".has_nodes" do
    it "adds node type to class's node_types" do
      TestAssociatedNodes.node_types.should include(:foos)
    end

    specify "#foos returns mutable foos collection" do
      construct.nodes(:foos) << foo
      construct.foos.should == [foo]
    end

    specify "#append_foo adds a foo to nested foos collection" do
      construct.nodes(:foos) << foo
      construct.nodes(:foos).should include(foo)
    end

    specify "#find_foo returns node with corresponding name" do
      construct.nodes(:foos) << foo
      construct.find_foo(:bar).should == foo
    end

    describe "#has_foos?" do
      context "when there are no foos" do
        it "return false" do
          construct.has_foos?.should be_false
        end
      end

      context "when there are some foos" do
        it "returns true" do
          construct.nodes(:foos) << foo
          construct.has_foos?.should be_true
        end
      end
    end
  end

  describe "#find" do
    context "when node is present" do
      it "returns node object with corresponding name" do
        construct.nodes(:foos) << foo
        construct.find(:foo, :bar).should == foo
      end
    end

    context "when node is absent" do
      it "yields if block given" do
        expect { |b| construct.find(:foo, :bar, &b) }.to yield_control
      end

      it "raises KeyError if no block given" do
        expect { construct.find(:foo, :bar) }.to raise_error(KeyError)
      end
    end
  end

  describe "#nodes" do
    it "returns nodes collection by plural name" do
      construct.nodes(:foos) << foo
      construct.nodes(:foos).should == [foo]
    end

    it "raises NodesNotDefinedError if non-specified node requested" do
      expect { construct.nodes(:bars) }.to raise_error(NodesNotDefinedError, /bars/)
    end
  end

  describe "#has_nodes?" do
    context "when nodes are present" do
      it "returns true" do
        construct.nodes(:foos) << foo
        construct.has_nodes?(:foos).should be_true
      end
    end

    context "when nodes are absent" do
      it "returns false" do
        construct.has_nodes?(:foos).should be_false
      end
    end

    it "raises if node can not have children of specified type" do
      expect { construct.has_nodes?(:quack) }.to raise_error NodesNotDefinedError
    end
  end
end

