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
  it { should have_accessor(:default_command) }
  it { should have_accessor(:global_alias) }
  it { should have_accessor(:identity_file) }

  module Taketo
    module Constructs
      Command = Class.new unless defined? Command
    end
  end

  it "has default command" do
    Taketo::Constructs::Command.should_receive(:default).and_return(:qux)
    expect(server.default_command).to eq(:qux)
  end

  describe "#environment=" do
    let(:environment) { environment = stub(:Environment, :name => :the_environment) }

    it "sets environment" do
      server.environment = environment
      expect(server.environment).to eq(environment)
    end

    it "sets RAILS_ENV environment variable" do
      server.environment_variables.should == {}
      server.environment = environment
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


