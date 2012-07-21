require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/command'

include Taketo

describe "Command" do
  let(:cmd) { Taketo::Constructs::Command.new(:the_command) }

  specify "#command= should set which command to execute" do
    cmd.command= "rails c"
    cmd.command.should == "rails c"
  end

  describe "#render" do
    it "should pick up server's environment variables and location" do
      server = mock(:Server, :environment_variables => { :FOO => "bar baz" }, :default_location => "/var/apps/the app")
      cmd.command = "rails c"
      cmd.render(server).should == "cd /var/apps/the\\ app; FOO=bar\\ baz rails c"
    end
  end
end

