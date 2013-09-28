require 'spec_helper'

include Taketo

describe "ConstructsFactory" do
  let(:factory) { Taketo::ConstructsFactory.new }

  specify "#create delegates to appropriate method according to the type" do
    factory.should_receive(:create_config)
    factory.create(:config)

    factory.should_receive(:create_project).with(:foo)
    factory.create(:project, :foo)
  end

  specify "#create_config creates a config object" do
    expect(factory.create_config).to be_an_instance_of(Taketo::Constructs::Config)
  end

  specify "#create_project creates a project object" do
    project = factory.create_project(:foo)
    expect(project).to be_an_instance_of(Taketo::Constructs::Project)
  end

  specify "#create_environment creates an environment object" do
    environment = factory.create_environment(:foo)
    expect(environment).to be_an_instance_of(Taketo::Constructs::Environment)
  end

  specify "#create_server creates a server object" do
    server = factory.create_server(:foo)
    expect(server).to be_an_instance_of(Taketo::Constructs::Server)
  end

  specify "#create_group creates a group object" do
    group = factory.create_group(:foo)
    expect(group).to be_an_instance_of(Taketo::Constructs::Group)
  end

  specify "#create_command creates a command object" do
    command = factory.create_command(:foo)
    expect(command).to be_an_instance_of(Taketo::Constructs::Command)
  end
end

