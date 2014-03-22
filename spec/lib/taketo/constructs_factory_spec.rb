require 'spec_helper'

module Taketo

  describe ConstructsFactory do
    let(:factory) { ConstructsFactory.new }

    specify "#create delegates to appropriate method according to the type" do
      factory.should_receive(:create_config)
      factory.create(:config)

      factory.should_receive(:create_project).with(:foo)
      factory.create(:project, :foo)
    end

    specify "#create_config creates a config object" do
      expect(factory.create_config).to be_an_instance_of(Constructs::Config)
    end

    specify "#create_project creates a project object" do
      project = factory.create_project(:foo)
      expect(project).to be_an_instance_of(Constructs::Project)
    end

    specify "#create_environment creates an environment object" do
      environment = factory.create_environment(:foo)
      expect(environment).to be_an_instance_of(Constructs::Environment)
    end

    specify "#create_server creates a server object" do
      server = factory.create_server(:foo)
      expect(server).to be_an_instance_of(Constructs::Server)
    end

    specify "#create_group creates a group object" do
      group = factory.create_group(:foo)
      expect(group).to be_an_instance_of(Constructs::Group)
    end
  end

end
