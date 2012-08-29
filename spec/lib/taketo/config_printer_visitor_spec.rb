require 'spec_helper'
require 'taketo/config_printer_visitor'

include Taketo

describe "ConfigPrinterVisitor" do
  describe "#visit_command" do
    let(:command) { stub(:Command, :name => :foo, :description => nil) }

    it "should render command name" do
      printer.visit_command(command)
      printer.result.should == "foo"
    end

    it "should also render description if available" do
      command.stub(:description => "The description")
      printer.visit_command(command)
      printer.result.should == "foo - The description"
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
           :environment_variables => { :FOO => "bar", :BOO => "baz" })
    end

    it "should render available server info" do
      server.stub(:has_commands? => true)
      printer.visit_server(server)
      printer.result.should =~ 
%r[Server: sponge
  Host: 1\.2\.3\.4
  Port: 8000
  User: bob
  Default location: /var/app
  Environment: (FOO=bar BOO=baz|BOO=baz FOO=bar)]
    end

    it "should render appropriate message if there are no commands" do
      server.stub(:has_commands? => false)
      printer.visit_server(server)
      printer.result.should include("(No commands)")
    end
  end

  describe "#visit_environment" do
    let(:environment) { stub(:Environment, :name => :foo) }

    it "should render environment info" do
      environment.stub(:has_servers? => true)
      printer.visit_environment(environment)
      printer.result.should == "Environment: foo"
    end

    it "should render appropriate message if there are no servers" do
      environment.stub(:has_servers? => false)
      printer.visit_environment(environment)
      printer.result.should include("Environment: foo\n  (No servers)")
    end
  end

  describe "#visit_project" do
    let(:project) { stub(:Project, :name => :quux) }

    it "should render project info" do
      project.stub(:has_environments? => true)
      printer.visit_project(project)
      printer.result.should == "\nProject: quux"
    end

    it "should render appropriate message if there are no environments for project" do
      project.stub(:has_environments? => false)
      printer.visit_project(project)
      printer.result.should == "\nProject: quux\n  (No environments)"
    end
  end

  describe "#visit_config" do
    let(:config) { stub(:Config, :default_destination => "hello:bye") }

    it "should render default destination and all projects" do
      config.stub(:has_projects? => true)
      printer.visit_config(config)
      printer.result.should == "Default destination: hello:bye"
    end

    it "should render appropriate message if there are no projects" do
      config.stub(:has_projects? => false)
      printer.visit_config(config)
      printer.result.should == "There are no projects yet..."
    end
  end

  it "should indent relatively" do
    config = stub(:Config, :default_destination => "hello:bye", :has_projects? => true)
    project = stub(:Project, :name => :quux, :has_environments? => true)
    environment = stub(:Environment, :name => :foo, :has_servers? => false)
    printer.visit_config(config)
    printer.visit_project(project)
    printer.visit_environment(environment)
    printer.result.should == "Default destination: hello:bye\n\nProject: quux\n  Environment: foo\n    (No servers)"
  end

  def printer
    @printer ||= ConfigPrinterVisitor.new
  end
end

