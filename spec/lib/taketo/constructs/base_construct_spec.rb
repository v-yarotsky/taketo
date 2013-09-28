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
        parent = stub
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

    describe "#path" do
      include_context "parents"

      it "returns names of parents separated by :" do
        expect(construct.path).to eq("grand_parent:parent:my_node")
      end
    end

    describe "#default_server_config=" do
      let(:default_server_config) { proc { call_from_self } }
      let(:context) { stub(:Context) }

      it "sets default server config" do
        construct.default_server_config = default_server_config
        context.should_receive(:call_from_self)
        context.instance_eval(&construct.default_server_config)
      end

      it "merges given config to parent's default server config" do
        construct.parent = stub(:default_server_config => proc { call_from_parent })
        construct.default_server_config = default_server_config

        context.should_receive(:call_from_parent).ordered
        context.should_receive(:call_from_self).ordered
        context.instance_eval(&construct.default_server_config)
      end
    end

    it "has an empty proc as an initial default server config" do
      expect(construct.default_server_config.call).to eq(nil)
    end

  end

end

