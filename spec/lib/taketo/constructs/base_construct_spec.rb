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

end


