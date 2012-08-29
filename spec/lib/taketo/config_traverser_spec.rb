require 'spec_helper'
require 'taketo/config_traverser'

# config           1
#                 / \
# project        1   2
#               / \ 
# environment  1   2
#                 /|\
# server         1 2 3

describe Taketo::ConfigTraverser do
  let(:server_1) { stub(:Server1, :node_type => :server, :name => :server_1).as_null_object }
  let(:server_2) { stub(:Server2, :node_type => :server, :name => :server_2).as_null_object }
  let(:server_3) { stub(:Server3, :node_type => :server, :name => :server_3).as_null_object }

  let(:environment_1) { stub(:Environment1, :node_type => :environment, :name => :environment_1) }
  let(:environment_2) { stub(:Environment2, :node_type => :environment, :name => :environment_2, :servers => [server_1, server_2, server_3]) }

  let(:project_1) { stub(:Project1, :node_type => :project, :name => :project_1, :environments => [environment_1, environment_2]) }
  let(:project_2) { stub(:Project2, :node_type => :project, :name => :project_2) }

  let(:config) { stub(:Config, :node_type => :config, :projects => [project_1, project_2], :name => :config) }

  let(:traverser) { described_class.new(config) }

  before do
    config.stub(:has_nodes?).with(:projects).and_return(true)
    config.stub(:nodes).with(:projects).and_return([project_1, project_2])

    project_1.stub(:has_nodes?).with(:environments).and_return(true)
    project_1.stub(:nodes).with(:environments).and_return([environment_1, environment_2])

    project_2.stub(:has_nodes?).with(:environments).and_return(false)
    project_2.should_not_receive(:nodes)

    environment_1.stub(:has_nodes?).with(:servers).and_return(false)
    environment_1.should_not_receive(:nodes)

    environment_2.stub(:has_nodes?).with(:servers).and_return(true)
    environment_2.stub(:nodes).and_return([server_1, server_2, server_3])
  end

  describe "#get_all_of_level" do
    it "should get a config if :config passed" do
      traverser.get_all_of_level(:config).to_a.should == [config]
    end

    it "should get all projects if :project passed" do
      traverser.get_all_of_level(:project).to_a.should == [project_1, project_2]
    end

    it "should get all environments if :environment passed" do
      traverser.get_all_of_level(:environment).to_a.should == [environment_1, environment_2]
    end

    it "shoudl get all servers if :server passed" do
      traverser.get_all_of_level(:server).to_a.should == [server_1, server_2, server_3]
    end
  end

  class PrintingVisitor
    def initialize
      @result = []
    end

    def visit(type)
    end
  end

  describe "#visit_depth_first" do
    it "should traverse in depth with visitor" do
      visitor = stub(:Visitor)
      [config, project_2, project_1, environment_2, server_3, server_2, server_1, environment_1].each do |node|
        node.should_receive(:accept).with(visitor).ordered
      end
      traverser.visit_depth_first(visitor)
    end
  end
end

