require 'spec_helper'
require 'taketo/support/named_nodes_collection'

describe "NamedNodesCollection" do
  let(:collection) { Taketo::Support::NamedNodesCollection.new }
  let(:node1) { stub(:name => :foo) }
  let(:node2) { stub(:name => :bar) }

  it "should be able to initialize with array" do
    Taketo::Support::NamedNodesCollection.new([1, 2, 3]).length.should == 3
  end

  it "should mimic Array" do
    collection.should be_empty
    collection << node1
    collection.push node2
    collection[0].should == node1
    collection[:foo].should == node1
    collection.map(&:name).should == [:foo, :bar]
    collection.length.should == 2
    collection.size.should == 2
    collection.first.should == node1
    collection.last.should == node2
  end

  it "should raise error if element not found" do
    expect { collection[3] }.to raise_error KeyError, /#3/i
    expect { collection[:quux] }.to raise_error KeyError, /name/i
  end

  it "should not add if node with same name exists" do
    collection << node1
    collection.push node1
    collection.length.should == 1
    collection.first.should == node1
  end

  it "should compare itself to array" do
    collection << node1
    collection.should == [node1]
  end
end


