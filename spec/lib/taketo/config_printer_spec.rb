require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/config_printer'

include Taketo

describe "ConfigPrinter" do
  describe "#render" do
    it "should render based on node class name" do
      printer.should_receive(:render_fixnum)
      printer.render(1)
    end
  end

  describe "#render_command" do
    let(:command) { stub(:Command, :name => :foo, :description => nil) }

    it "should render command name" do
      printer.render_command(command).should == "foo"
    end

    it "should also render description if available" do
      command.stub(:description => "The description")
      printer.render_command(command).should == "foo - The description"
    end
  end

  describe "#render_server" do
    let(:server) do
      stub(:Server,
           :name => :sponge,
           :host => "1.2.3.4",
           :port => 8000,
           :username => "bob",
           :default_location => "/var/app",
           :environment_variables => { :FOO => "bar", :BOO => "baz" })
    end

    it "should render available server info and commands" do
      server.stub(:commands => [:the_command])
      printer.should_receive(:render_command).with(:the_command)
      printer.render_server(server).should =~ 
%r[Server: sponge
  Host: 1\.2\.3\.4
  Port: 8000
  User: bob
  Default location: /var/app
  Environment: (FOO=bar BOO=baz|BOO=baz FOO=bar)
  Commands:]
    end

    it "should not render commands if there are none" do
      server.stub(:commands => [])
      printer.render_server(server).should_not include("Commands:")
    end
  end

  describe "#render_environment" do
    let(:environment) do
      stub(:Environment,
           :name => :foo)
    end

    it "should render environment info and servers" do
      environment.stub(:servers => [:the_server])
      printer.should_receive(:render_server).with(:the_server)
      printer.render_environment(environment).should == "Environment: foo"
    end

    it "should render appropriate message if there are no servers" do
      environment.stub(:servers => [])
      printer.render_environment(environment).should == "Environment: foo (No servers)"
    end
  end

  describe "#render_project" do
    let(:project) do
      stub(:Project,
           :name => :quux)
    end

    it "should render project info and it's environments" do
      project.stub(:environments => [:the_environment])
      printer.should_receive(:render_environment).with(:the_environment)
      printer.render_project(project).should == "Project: quux\n"
    end

    it "should render appropriate message if there are no environments for project" do
      project.stub(:environments => [])
      printer.render_project(project).should == "Project: quux (No environments)\n"
    end
  end

  describe "#render_config" do
    let(:config) do
      stub(:Config,
           :default_destination => "hello:bye")
    end

    it "should render default destination and all projects" do
      config.stub(:projects => [:the_project])
      printer.should_receive(:render_project).with(:the_project)
      printer.render_config(config).should == "\nDefault destination: hello:bye"
    end

    it "should render appropriate message if there are no projects" do
      config.stub(:projects => [])
      printer.render_config(config).should == "There are no projects yet..."
    end
  end

  def printer
    @printer ||= ConfigPrinter.new
  end
end

