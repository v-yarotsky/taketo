require 'spec_helper'

module Taketo::ConfigVisitors

  describe PrinterVisitor do
    subject(:printer) { PrinterVisitor.new }

    describe "#visit_command" do
      let(:command) { double(:Command, :name => :foo, :description => nil) }

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
        double(:Server,
               :name => :sponge,
               :host => "1.2.3.4",
               :port => 8000,
               :username => "bob",
               :default_location => "/var/app",
               :default_command => "tmux",
               :environment_variables => { :FOO => "bar", :BOO => "baz" })
      end

      it "renders available server info" do
        expect(server).to receive(:has_nodes?).with(:command).and_return(false)
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
        expect(server).to receive(:has_nodes?).with(:command).and_return(false)
        printer.visit_server(server)
        expect(printer.result).not_to match(/commands/i)
      end

      it "renders commands if defined" do
        expect(server).to receive(:has_nodes?).with(:command).and_return(true)
        printer.visit_server(server)
        expect(printer.result).to include("Commands:")
      end
    end

    describe "#visit_environment" do
      let(:environment) { double(:Environment, :name => :foo) }

      it "renders environment info" do
        expect(environment).to receive(:has_nodes?).with(:server).and_return(true)
        printer.visit_environment(environment)
        expect(printer.result).to eq("Environment: foo")
      end

      it "renders appropriate message if there are no servers" do
        expect(environment).to receive(:has_nodes?).with(:server).and_return(false)
        printer.visit_environment(environment)
        expect(printer.result).to include("Environment: foo\n  (No servers)")
      end
    end

    describe "#visit_project" do
      let(:project) { double(:Project, :name => :quux) }

      it "renders project info" do
        expect(project).to receive(:has_nodes?).with(:environment).and_return(true)
        printer.visit_project(project)
        expect(printer.result).to eq("\nProject: quux")
      end

      it "renders appropriate message if there are no environments for project" do
        expect(project).to receive(:has_nodes?).with(:environment).and_return(false)
        printer.visit_project(project)
        expect(printer.result).to eq("\nProject: quux\n  (No environments)")
      end
    end

    describe "#visit_config" do
      let(:config) { double(:Config, :default_destination => "hello:bye") }

      it "renders default destination and all projects" do
        expect(config).to receive(:has_nodes?).with(:project).and_return(true)
        printer.visit_config(config)
        expect(printer.result).to eq("Default destination: hello:bye")
      end

      it "renders appropriate message if there are no projects" do
        expect(config).to receive(:has_nodes?).with(:project).and_return(false)
        printer.visit_config(config)
        expect(printer.result).to eq("There are no projects yet...")
      end
    end

    it "indents relatively" do
      config = double(:Config, :default_destination => "hello:bye")
      expect(config).to receive(:has_nodes?).with(:project).and_return(true)
      project = double(:Project, :name => :quux)
      expect(project).to receive(:has_nodes?).with(:environment).and_return(true)
      environment = double(:Environment, :name => :foo)
      expect(environment).to receive(:has_nodes?).with(:server).and_return(false)
      printer.visit_config(config)
      printer.visit_project(project)
      printer.visit_environment(environment)
      expect(printer.result).to eq("Default destination: hello:bye\n\nProject: quux\n  Environment: foo\n    (No servers)")
    end
  end

end

