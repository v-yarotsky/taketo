require 'spec_helper'
require 'taketo/constructs/base_construct'

include Taketo

describe "BaseConstruct" do
  class TestBaseConstruct < Constructs::BaseConstruct; end

  subject(:construct) { TestBaseConstruct.new(:my_node) }

  specify "#node_type returns demodulized snake-cased class name" do
    construct.node_type.should == :test_base_construct
  end

  specify "#qualified_name returns node type and name as string" do
    expect(construct.qualified_name).to eq('test_base_construct my_node')
  end

  specify "#parent= sets default server config to parent's default server config" do
    parent_default_server_config = proc {}
    construct.parent = stub(:default_server_config => parent_default_server_config)
    expect(construct.default_server_config).to eq(parent_default_server_config)
  end

  describe "#default_server_config=" do
    let(:default_server_config) { proc { call_from_self } }
    let(:context) { stub }

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


