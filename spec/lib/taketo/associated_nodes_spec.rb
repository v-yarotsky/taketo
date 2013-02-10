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
      expect(TestAssociatedNodes.node_types).to include(:foos)
    end

    specify "#foos returns mutable foos collection" do
      construct.nodes(:foos) << foo
      expect(construct.foos).to eq([foo])
    end

    specify "#append_foo adds a foo to nested foos collection" do
      construct.nodes(:foos) << foo
      expect(construct.nodes(:foos)).to include(foo)
    end

    specify "#find_foo returns node with corresponding name" do
      construct.nodes(:foos) << foo
      expect(construct.find_foo(:bar)).to eq(foo)
    end

    describe "#has_foos?" do
      context "when there are no foos" do
        it "returns false" do
          expect(construct).not_to have_foos
        end
      end

      context "when there are some foos" do
        it "returns true" do
          construct.nodes(:foos) << foo
          expect(construct).to have_foos
        end
      end
    end
  end

  describe "#find" do
    context "when node is present" do
      it "returns node object with corresponding name" do
        construct.nodes(:foos) << foo
        expect(construct.find(:foo, :bar)).to eq(foo)
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
      expect(construct.nodes(:foos)).to eq([foo])
    end

    it "raises NodesNotDefinedError if non-specified node requested" do
      expect { construct.nodes(:bars) }.to raise_error(NodesNotDefinedError, /bars/)
    end
  end

  describe "#has_nodes?" do
    context "when nodes are present" do
      it "returns true" do
        construct.nodes(:foos) << foo
        expect(construct).to have_nodes(:foos)
      end
    end

    context "when nodes are absent" do
      it "returns false" do
        expect(construct).not_to have_nodes(:foos)
      end
    end

    it "raises if node can not have children of specified type" do
      expect { construct.has_nodes?(:quack) }.to raise_error NodesNotDefinedError
    end
  end

  describe "#has_deeply_nested_nodes?" do
    class TestNestedNodes
      include AssociatedNodes

      def name; :foo; end

      has_nodes :foos, :foo
      has_nodes :bars, :bar
    end

    subject(:construct) { TestNestedNodes.new }
    let(:foo) { TestNestedNodes.new }

    context "directly nested nodes" do
      it "returns true when present" do
        construct.nodes(:foos) << foo
        expect(construct).to have_deeply_nested_nodes(:foos)
      end
    end

    context "indirectly nested nodes" do
      before(:each) { construct.nodes(:foos) << foo }

      it "returns true when present" do
        foo.nodes(:bars) << stub(:Bar, :name => :bar)
        expect(construct).to have_deeply_nested_nodes(:bars)
      end

      it "returns false when not present" do
        expect(construct).not_to have_deeply_nested_nodes(:bars)
      end
    end
  end
end

