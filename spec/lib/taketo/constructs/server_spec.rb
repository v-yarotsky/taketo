require 'spec_helper'

module Taketo::Constructs

  describe Server do
    subject(:server) { Server.new(:foo) }

    it "has name" do
      expect(server.name).to eq(:foo)
    end

    module Taketo
      module Constructs
        Command = Class.new unless defined? Command
      end
    end

    it "can not have children" do
      expect(server.allowed_node_types).to be_empty
    end

    describe "#fetch_command" do
      let(:command) { ::Taketo::Support::Command.explicit_command("echo") }

      before(:each) do
        server.config = ::Taketo::Support::ServerConfig.new(:commands => [command])
      end

      it "returns command by name if found" do
        expect(server.fetch_command("echo")).to eq(command)
      end

      it "returns explicit command if not found by name" do
        expect(server.fetch_command("shutdown -h now")).to eq(::Taketo::Support::Command.explicit_command("shutdown -h now"))
      end
    end

    # check delegating to config
  end

end

