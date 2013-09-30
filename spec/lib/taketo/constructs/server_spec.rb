require 'spec_helper'

module Taketo::Constructs

  describe Server do
    subject(:server) { Server.new(:foo) }

    it "has name" do
      expect(server.name).to eq(:foo)
    end

    it { should have_accessor(:host) }
    it { should have_accessor(:port) }
    it { should have_accessor(:username) }
    it { should have_accessor(:default_location) }
    it { should have_accessor(:global_alias, "something") }
    it { should have_accessor(:identity_file) }

    module Taketo
      module Constructs
        Command = Class.new unless defined? Command
      end
    end

    describe "#default_command" do
      before(:each) { stub_const("Taketo::Constructs::Command", Class.new) }

      it "returns Command.default if nothing defined" do
        Command.should_receive(:default).and_return(:qux)
        expect(server.default_command).to eq(:qux)
      end

      it "returns existing defined command if default command name is set" do
        command = double(:Command, :name => :foo, :node_type => :command).as_null_object
        server.add_node(command)
        server.default_command = :foo
        expect(server.default_command).to eq(command)
      end

      it "returns explicit command if default command not found by name" do
        command = double(:Command)
        Command.should_receive(:explicit_command).with("tmux attach || tmux new-session").and_return(command)
        server.default_command = "tmux attach || tmux new-session"
        expect(server.default_command).to eq(command)
      end
    end

    describe "#parent=" do
      let(:environment) { double(:Environment, :rails_env => 'the_env') }

      it "sets RAILS_ENV environment variable" do
        server.environment_variables.should == {}
        server.parent = environment
        expect(server.environment_variables[:RAILS_ENV]).to eq(environment.rails_env)
      end

      it "does not fail if parent doesn't provide #rails_env" do
        expect { server.parent = 1 }.not_to raise_error
      end
    end

    describe "#ssh_command" do
      it "stores symbol" do
        server.ssh_command = "ohai"
        expect(server.ssh_command).to eq(:ohai)
      end

      it "has #ssh_command = :ssh by default" do
        expect(server.ssh_command).to eq(:ssh)
      end
    end

    specify "#global_alias= stores string" do
      server.global_alias = :foo
      expect(server.global_alias).to eq("foo")
    end

    it "sets environment variables" do
      server.env :FOO => "bar"
      server.env :BAR => "baz"
      expect(server.environment_variables).to include(:FOO => "bar", :BAR => "baz")
    end

    it "allows only commands as children" do
      server.allowed_node_types.should =~ [:command]
    end
  end

end

