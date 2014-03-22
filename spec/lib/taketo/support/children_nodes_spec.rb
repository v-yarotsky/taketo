require 'spec_helper'

module Taketo
  module Support

    class TestChildrenNodesConstruct
      include ChildrenNodes

      accepts_node_types :project, :server

      def node_type
        :test_children_nodes_construct
      end
    end

    describe ChildrenNodes do
      subject(:construct) { TestChildrenNodesConstruct.new }

      describe ".accepts_node_types" do
        it "makes only certain types of nodes to be allowed as children" do
          expect(construct.allowed_node_types).to eq([:project, :server])
        end
      end

      it "does not allow any children nodes by default" do
        new_construct_class = Class.new { include ChildrenNodes }
        expect(new_construct_class.new.allowed_node_types).to eq([])
      end

      let(:project) { double(:Project, :node_type => :project, :name => :foo).as_null_object }
      let(:server)  { double(:Server,  :node_type => :server,  :name => :foo).as_null_object }
      let(:server_command) { double(:Command, :node_type => :command, :name => :foo).as_null_object }

      it "has nested nodes" do
        construct.add_node(project)
        expect(construct.nodes).to include(project)
      end

      it "sets child node's parent when adding" do
        expect(project).to receive(:parent=).with(construct)
        construct.add_node(project)
      end

      it "does not add same node twice" do
        construct.add_node(project)
        construct.add_node(project)
        expect(construct.nodes).to eq([project])
      end

      it "does not add nodes which are not allowed" do
        expect do
          construct.add_node(server_command)
        end.to raise_error(/command can not be added in test_children_nodes_construct scope/)
      end

      it "allows searching node of certain type by name" do
        construct.add_node(project)
        construct.add_node(server)
        expect(construct.find_node_by_type_and_name(:project, :foo)).to eq(project)
        expect(construct.find_node_by_type_and_name(:server,  :foo)).to eq(server)
      end

      it "yields unless matching node found" do
        expect do |b|
          construct.find_node_by_type_and_name(:project, :foo, &b)
        end.to yield_control
      end

      it "has #has_nodes? query" do
        construct.add_node(project)
        expect(construct.has_nodes?(:project)).to be_true
        expect(construct.has_nodes?(:environment)).to be_false
      end

      describe "#<<" do
        it "adds nodes" do
          construct << project
          expect(construct.nodes).to eq([project])
        end

        it "is chainable" do
          construct << project << server
          expect(construct.nodes).to eq([project, server])
        end

        it "sets child node parent" do
          expect(project).to receive(:parent=).with(construct)
          expect(server).to receive(:parent=).with(construct)
          construct << project << server
        end
      end
    end

  end
end

