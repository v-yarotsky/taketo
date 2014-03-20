require 'spec_helper'

module Taketo::Constructs

  describe BaseConstruct do
    class TestBaseConstruct < BaseConstruct; end

    subject(:construct) { TestBaseConstruct.new(:my_node) }

    specify "#node_type returns demodulized snake-cased class name" do
      construct.node_type.should == :test_base_construct
    end

    specify "#qualified_name returns node type and name as string" do
      expect(construct.qualified_name).to eq('test_base_construct my_node')
    end

    describe "#parent=" do
      it "stores parent" do
        parent = double
        construct.parent = parent
        construct.parent.should == parent
      end
    end

    shared_context "parents" do
      let(:grand_parent) { TestBaseConstruct.new(:grand_parent) }
      let(:parent) { TestBaseConstruct.new(:parent) }

      before(:each) do
        parent.parent = grand_parent
        construct.parent = parent
      end
    end

    describe "#parents" do
      include_context "parents"

      it "returns parent nodes up until NullConstruct" do
        expect(construct.parents).to eq([parent, grand_parent])
      end
    end

    specify "#parents returns an empty array if there are no parents" do
      expect(construct.parents).to eq([])
    end

    it "should be able to have children nodes" do
      expect(construct).to be_kind_of(::Taketo::Support::ChildrenNodes)
    end

    describe ".new" do
      it "yields self" do
        expect { |b| TestBaseConstruct.new(:my_node, &b) }.to yield_control
      end
    end
  end

end

