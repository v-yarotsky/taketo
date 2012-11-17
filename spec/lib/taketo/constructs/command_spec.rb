require 'spec_helper'
require 'taketo/constructs/command'

include Taketo

describe "Command" do
  subject(:command) { Taketo::Constructs::Command.new(:the_command) }

  it { should have_accessor(:command) }
  it { should have_accessor(:description) }

  describe "#render" do
    let(:server) do
      mock(:Server,
           :environment_variables => { :FOO => "bar baz" },
           :default_location => "/var/apps/the app")
    end

    it "picks up server's environment variables and location" do
      command.command = "rails c"
      expect(command.render(server)).to eq("cd /var/apps/the\\ app; FOO=bar\\ baz rails c")
    end

    it "lets user override default directory" do
      command.command = "rails c"
      expect(command.render(server, :directory => "/var/qux")).to eq("cd /var/qux; FOO=bar\\ baz rails c")
    end
  end

  describe ".default" do
    it "returns 'bash' command" do
      expect(Taketo::Constructs::Command.default.command).to eq("bash")
    end
  end

  describe ".explicit_command" do
    it "returns given command string encapsulated" do
      expect(Taketo::Constructs::Command.explicit_command("qq").command).to eq("qq")
    end
  end

  specify "#to_s returns just command" do
    command.command = "hello_there"
    expect(command.to_s).to eq("hello_there")
  end
end

