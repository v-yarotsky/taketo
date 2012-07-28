require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/command'

include Taketo

describe "Command" do
  subject { Taketo::Constructs::Command.new(:the_command) }

  it { should have_accessor(:command) }
  it { should have_accessor(:description) }

  describe "#render" do
    let(:server) do
      mock(:Server,
           :environment_variables => { :FOO => "bar baz" },
           :default_location => "/var/apps/the app")
    end

    it "should pick up server's environment variables and location" do
      subject.command = "rails c"
      subject.render(server).should == "cd /var/apps/the\\ app; FOO=bar\\ baz rails c"
    end

    it "should let user override default directory" do
      subject.command = "rails c"
      subject.render(server, :directory => "/var/qux").should == "cd /var/qux; FOO=bar\\ baz rails c"
    end
  end

  describe ".default" do
    it "should return 'bash' command" do
      Taketo::Constructs::Command.default.command.should == "bash"
    end
  end

  describe ".explicit_command" do
    it "should return given command string encapsulated" do
      Taketo::Constructs::Command.explicit_command("qq").command.should == "qq"
    end
  end
end

