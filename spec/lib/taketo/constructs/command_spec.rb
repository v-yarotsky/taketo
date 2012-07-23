require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/command'

include Taketo

describe "Command" do
  let(:cmd) { Taketo::Constructs::Command.new(:the_command) }

  specify "#command= should set which command to execute" do
    cmd.command= "rails c"
    cmd.command.should == "rails c"
  end

  specify "#description= should set command description" do
    cmd.description= "Run rails console"
    cmd.description.should == "Run rails console"
  end

  describe "#render" do
    let(:server) { mock(:Server, :environment_variables => { :FOO => "bar baz" }, :default_location => "/var/apps/the app") }

    it "should pick up server's environment variables and location" do
      cmd.command = "rails c"
      cmd.render(server).should == "cd /var/apps/the\\ app; FOO=bar\\ baz rails c"
    end

    it "should let user override default directory" do
      cmd.command = "rails c"
      cmd.render(server, :directory => "/var/qux").should == "cd /var/qux; FOO=bar\\ baz rails c"
    end
  end
end

