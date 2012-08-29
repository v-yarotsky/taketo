require 'spec_helper'
require 'taketo/config_validator'

include Taketo

describe "ConfigValidator" do
  let(:traverser) { stub(:ConfigTraverser) }

  def validator(traverser)
    Taketo::ConfigValidator.new(traverser)
  end

  it "should require at least one project" do
    config = stub(:Config, :has_projects? => false)
    traverser.should_receive(:get_all_of_level).with(:config).and_return([config])
    expect { validator(traverser).ensure_projects_exist }.to raise_error ConfigError, /projects/i
  end

  it "should require every project to have at least one environment" do
    project = stub(:Project, :name => :project_1)
    traverser.should_receive(:get_all_of_level).with(:project).twice.and_return([project])

    project.should_receive(:has_environments?).and_return(false)
    expect { validator(traverser).ensure_environments_exist }.to raise_error ConfigError, /project_1/i

    project.should_receive(:has_environments?).and_return(true)
    expect { validator(traverser).ensure_environments_exist }.not_to raise_error ConfigError, /project_1/i
  end

  it "should require every environment to have at least one server" do
    environment = stub(:Environment, :name => :environment_1, :project_name => "Qux")
    traverser.should_receive(:get_all_of_level).with(:environment).twice.and_return([environment])

    environment.should_receive(:has_servers?).and_return(false)
    expect { validator(traverser).ensure_servers_exist }.to raise_error ConfigError, /environment_1/i

    environment.should_receive(:has_servers?).and_return(true)
    expect { validator(traverser).ensure_servers_exist }.not_to raise_error ConfigError, /environment_2/i
  end

  describe "global server aliases" do
    let(:server_1) { stub(:Server) }
    let(:server_2) { stub(:Server) }

    it "should not raise error if unique" do
      server_1.stub(:global_alias => :foo)
      server_2.stub(:global_alias => :bar)
      traverser.should_receive(:get_all_of_level).with(:server).and_return([server_1, server_2])
      expect { validator(traverser).ensure_global_server_aliases_unique }.not_to raise_error(ConfigError, /alias/i)
    end

    it "should raise error unless unique" do
      server_1.stub(:global_alias => :foo)
      server_2.stub(:global_alias => :foo)
      traverser.should_receive(:get_all_of_level).with(:server).and_return([server_1, server_2])
      expect { validator(traverser).ensure_global_server_aliases_unique }.to raise_error(ConfigError, /alias/i)
    end
  end

  describe "#validate!" do
    let(:validator_instance) { validator(stub.as_null_object) }
    specify { validator_instance.should_receive(:ensure_projects_exist); validator_instance.validate! }
    specify { validator_instance.should_receive(:ensure_environments_exist); validator_instance.validate! }
    specify { validator_instance.should_receive(:ensure_servers_exist); validator_instance.validate! }
    specify { validator_instance.should_receive(:ensure_global_server_aliases_unique); validator_instance.validate! }
  end
end


