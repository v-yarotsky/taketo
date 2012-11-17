require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/server'

include Taketo

describe "Server" do
  subject(:server) { Taketo::Constructs::Server.new(:foo) }

  it "has name" do
    expect(server.name).to eq(:foo)
  end

  it { should have_accessor(:host) }
  it { should have_accessor(:port) }
  it { should have_accessor(:username) }
  it { should have_accessor(:default_location) }
  it { should have_accessor(:global_alias) }
  it { should have_accessor(:identity_file) }

  module Taketo
    module Constructs
      Command = Class.new unless defined? Command
    end
  end

  describe "#default_command" do
    before(:each) { stub_const("Taketo::Constructs::Command", Class.new) }

    it "returns Command.default if nothing defined" do
      Taketo::Constructs::Command.should_receive(:default).and_return(:qux)
      expect(server.default_command).to eq(:qux)
    end

    it "returns existing defined command if default command name is set" do
      command = stub(:Command, :name => :foo)
      server.commands << command
      server.default_command = :foo
      expect(server.default_command).to eq(command)
    end

    it "returns explicit command if default command not found by name" do
      command = stub(:Command)
      Taketo::Constructs::Command.should_receive(:explicit_command).with("tmux attach || tmux new-session").and_return(command)
      server.default_command = "tmux attach || tmux new-session"
      expect(server.default_command).to eq(command)
    end
  end

  describe "#parent=" do
    let(:environment) { environment = stub(:Environment, :name => :the_environment, :default_server_config => proc {}) }

    it { should have_accessor(:environment, environment) }

    it "sets RAILS_ENV environment variable" do
      server.environment_variables.should == {}
      server.parent = environment
      expect(server.environment_variables[:RAILS_ENV]).to eq(environment.name.to_s)
    end
  end

  it "sets environment variables" do
    server.env :FOO => "bar"
    server.env :BAR => "baz"
    expect(server.environment_variables).to include(:FOO => "bar", :BAR => "baz")
  end

  it_behaves_like "a construct with nodes", :commands, :command
end


