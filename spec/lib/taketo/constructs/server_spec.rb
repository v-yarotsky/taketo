require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/server'

include Taketo

describe "Server" do
  subject { Taketo::Constructs::Server.new(:foo) }

  it "should have name" do
    subject.name.should == :foo
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

  it "should have default command" do
    Taketo::Constructs::Command.should_receive(:default).and_return(:qux)
    subject.default_command.should == :qux
  end

  describe "#environment=" do
    let(:environment) { environment = stub(:Environment, :name => :the_environment) }

    it "should set environment" do
      subject.environment = environment
      subject.environment.should == environment
    end

    it "should set RAILS_ENV environment variable" do
      subject.environment_variables.should == {}
      subject.environment = environment
      subject.environment_variables[:RAILS_ENV].should == environment.name.to_s
    end
  end

  it "should set environment variables" do
    subject.env :FOO => "bar"
    subject.env :BAR => "baz"
    subject.environment_variables.should include(:FOO => "bar", :BAR => "baz")
  end

  it_behaves_like "a construct with nodes", :commands, :command
end


