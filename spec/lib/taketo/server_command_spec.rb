require 'spec_helper'

module Taketo

  describe ServerCommand do
    subject(:server_command) { ServerCommand.new(:foo) }

    it { should have_accessor(:name) }
    it { should have_accessor(:command) }
    it { should have_accessor(:description) }

    describe ".new" do
      it "yields self" do
        expect { |b| ServerCommand.new(:foo, &b) }.to yield_control
      end

      it "assigns name" do
        expect(ServerCommand.new(:foo).name).to eq("foo")
      end
    end

    describe ".explicit_command" do
      it "creates a command just from run-string" do
        server_command = ServerCommand.explicit_command("do foo")
        expect(server_command.command).to eq("do foo")
        expect(server_command.name).to eq("do foo")
      end
    end

    describe "==" do
      it "returns true if command name, command and description are same" do
        cmd1 = ServerCommand.new(:foo) { |c| c.command = "do foo"; c.description = "back off" }
        cmd2 = ServerCommand.new(:foo) { |c| c.command = "do foo"; c.description = "back off" }
        expect(cmd1).to eq(cmd2)
      end
    end

    specify "#to_s returns just command" do
      server_command.command = "hello_there"
      expect(server_command.to_s).to eq("hello_there")
    end
  end

end
