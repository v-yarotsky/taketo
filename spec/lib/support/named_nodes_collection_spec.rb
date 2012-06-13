require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/support/named_nodes_collection'

describe "NamedNodesCollection" do
  let(:collection) { Taketo::Support::NamedNodesCollection.new }
  let(:node1) { stub(:name => :foo) }
  let(:node2) { stub(:name => :bar) }

  it "should mimic Array" do
    collection.should be_empty
    collection << node1
    collection.push node2
    collection[0].should == node1
    collection.map(&:name).should == [:foo, :bar]
    collection.length.should == 2
    collection.size.should == 2
  end

  it "should raise error if element not found" do
    expect { collection[3] }.to raise_error KeyError, /#3/i
    expect { collection[:quux] }.to raise_error KeyError, /name/i
  end
end


