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
end

