require 'spec_helper'
require 'taketo/config_visitors'

module Taketo::ConfigVisitors

  describe PrinterVisitor do
    subject(:printer) { PrinterVisitor.new }

    describe "#visit_command" do
      let(:command) { stub(:Command, :name => :foo, :description => nil) }

      it "renders command name" do
        printer.visit_command(command)
        expect(printer.result).to eq("foo")
      end

      it "renders description if available" do
        command.stub(:description => "The description")
        printer.visit_command(command)
        expect(printer.result).to eq("foo - The description")
      end
    end

    describe "#visit_server" do
      let(:server) do
        stub(:Server,
            :name => :sponge,
            :host => "1.2.3.4",
            :port => 8000,
            :username => "bob",
            :default_location => "/var/app",
            :default_command => "tmux",
            :environment_variables => { :FOO => "bar", :BOO => "baz" })
      end

      it "renders available server info" do
        server.stub(:has_commands? => true)
        printer.visit_server(server)
        expect(printer.result).to match(
%r[Server: sponge
  Host: 1\.2\.3\.4
  Port: 8000
  User: bob
  Default location: /var/app
  Default command: tmux
  Environment: (FOO=bar BOO=baz|BOO=baz FOO=bar)])
      end

      it "does not renders commands section header if there are no commands defined" do
        server.stub(:has_commands? => false)
        printer.visit_server(server)
        expect(printer.result).not_to match(/commands/i)
      end

      it "renders commands if defined" do
        server.stub(:has_commands? => true)
        printer.visit_server(server)
        expect(printer.result).to include("Commands:")
      end
    end

    describe "#visit_environment" do
      let(:environment) { stub(:Environment, :name => :foo) }

      it "renders environment info" do
        environment.stub(:has_servers? => true)
        printer.visit_environment(environment)
        expect(printer.result).to eq("Environment: foo")
      end

      it "renders appropriate message if there are no servers" do
        environment.stub(:has_servers? => false)
        printer.visit_environment(environment)
        expect(printer.result).to include("Environment: foo\n  (No servers)")
      end
    end

    describe "#visit_project" do
      let(:project) { stub(:Project, :name => :quux) }

      it "renders project info" do
        project.stub(:has_environments? => true)
        printer.visit_project(project)
        expect(printer.result).to eq("\nProject: quux")
      end

      it "renders appropriate message if there are no environments for project" do
        project.stub(:has_environments? => false)
        printer.visit_project(project)
        expect(printer.result).to eq("\nProject: quux\n  (No environments)")
      end
    end

    describe "#visit_config" do
      let(:config) { stub(:Config, :default_destination => "hello:bye") }

      it "renders default destination and all projects" do
        config.stub(:has_projects? => true)
        printer.visit_config(config)
        expect(printer.result).to eq("Default destination: hello:bye")
      end

      it "renders appropriate message if there are no projects" do
        config.stub(:has_projects? => false)
        printer.visit_config(config)
        expect(printer.result).to eq("There are no projects yet...")
      end
    end

    it "indents relatively" do
      config = stub(:Config, :default_destination => "hello:bye", :has_projects? => true)
      project = stub(:Project, :name => :quux, :has_environments? => true)
      environment = stub(:Environment, :name => :foo, :has_servers? => false)
      printer.visit_config(config)
      printer.visit_project(project)
      printer.visit_environment(environment)
      expect(printer.result).to eq("Default destination: hello:bye\n\nProject: quux\n  Environment: foo\n    (No servers)")
    end
  end

end

