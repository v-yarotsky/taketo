require 'spec_helper'
require 'taketo/support/named_nodes_collection'

include Taketo::Support

describe "NamedNodesCollection" do
  subject(:collection) { NamedNodesCollection.new }
  let(:node1) { stub(:name => :foo) }
  let(:node2) { stub(:name => :bar) }

  it "can be initialized with array" do
    expect(NamedNodesCollection.new([1, 2, 3]).length).to eq(3)
  end

  [:empty?, :each, :length, :size, :first, :last].each do |delegated_method|
    it { should respond_to(delegated_method) }
  end

  it "is Enumerable" do
    expect(collection).to be_kind_of(Enumerable)
  end

  describe "#[]" do
    subject(:collection) { NamedNodesCollection.new([node1]) }

    it "retrieves node by index" do
      expect(collection[0]).to eq(node1)
    end

    it "retrieves node by name" do
      expect(collection[:foo]).to eq(node1)
    end

    it "raises error if node not found" do
      expect { collection[3] }.to raise_error KeyError, /#3/i
      expect { collection[:quux] }.to raise_error KeyError, /name/i
    end
  end

  describe "#push, #<<" do
    it "adds node to the collection" do
      collection.push(node1)
      expect(collection.length).to eq(1)
      collection << node2
      expect(collection.length).to eq(2)
    end

    it "does nothing if node with same name exists" do
      collection.push(node1)
      collection.push(node1)
      expect(collection.length).to eq(1)
    end

    it "supports chaining" do
      collection << node1 << node2
      expect(collection.length).to eq(2)
    end
  end

  it "compares itself to array" do
    collection << node1
    expect(collection).to eq([node1])
  end
end


