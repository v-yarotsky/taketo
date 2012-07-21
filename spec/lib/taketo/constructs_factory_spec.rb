require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/constructs_factory'

include Taketo

describe "ConstructsFactory" do
  let(:factory) { Taketo::ConstructsFactory.new }

  specify "#create should delegate to appripriate method according to type" do
    factory.should_receive(:create_config)
    factory.create(:config)

    factory.should_receive(:create_project).with(:foo)
    factory.create(:project, :foo)
  end

  specify "#create_config should create a config object" do
    factory.create_config.should be_an_instance_of(Taketo::Constructs::Config)
  end

  specify "#create_project should create a project object" do
    project = factory.create_project(:foo)
    project.should be_an_instance_of(Taketo::Constructs::Project)
  end

  specify "#create_environment should create an environment object" do
    environment = factory.create_environment(:foo)
    environment.should be_an_instance_of(Taketo::Constructs::Environment)
  end

  specify "#create_server should create a server object" do
    server = factory.create_server(:foo)
    server.should be_an_instance_of(Taketo::Constructs::Server)
  end

  specify "#create_command should create a command object" do
    command = factory.create_command(:foo)
    command.should be_an_instance_of(Taketo::Constructs::Command)
  end
end

