require 'spec_helper'

module Taketo::Support

  describe Command do
    subject(:command) { Command.new(:foo) }

    it { should have_accessor(:name) }
    it { should have_accessor(:command) }
    it { should have_accessor(:description) } 

    describe ".new" do
      it "yields self" do
        expect { |b| Command.new(:foo, &b) }.to yield_control
      end
    end

    describe ".explicit_command" do
      it "creates a command just from run-string" do
        expect(Command.explicit_command("do foo").command).to eq("do foo")
      end
    end

    describe "==" do
      it "returns true if command name, command and description are same" do
        cmd1 = Command.new(:foo) { |c| c.command = "do foo"; c.description = "back off" }
        cmd2 = Command.new(:foo) { |c| c.command = "do foo"; c.description = "back off" }
        expect(cmd1).to eq(cmd2)
      end
    end
    
    specify "#to_s returns just command" do
      command.command = "hello_there"
      expect(command.to_s).to eq("hello_there")
    end
  end

end
