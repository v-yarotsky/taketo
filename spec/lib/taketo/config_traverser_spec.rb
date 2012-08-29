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
  let(:server_1) { stub(:Server, :node_type => :server, :name => :server_1) }
  let(:server_2) { stub(:Server, :node_type => :server, :name => :server_2) }
  let(:server_3) { stub(:Server, :node_type => :server, :name => :server_3) }

  let(:environment_1) { stub(:Environment, :node_type => :environment, :name => :environment_1) }
  let(:environment_2) { stub(:Environment, :node_type => :environment, :name => :environment_2, :servers => [server_1, server_2, server_3]) }

  let(:project_1) { stub(:Project, :node_type => :project, :name => :project_1, :environments => [environment_1, environment_2]) }
  let(:project_2) { stub(:Project, :node_type => :project, :name => :project_2) }

  let(:config) { stub(:Config, :node_type => :config, :projects => [project_1, project_2]) }

  let(:traverser) { described_class.new(config) }

  describe "#get_all_of_level" do
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
end

