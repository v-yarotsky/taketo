require 'spec_helper'

module Taketo
  module Constructs

    describe Server do
      subject(:server) { Server.new(:foo) }

      it "has name" do
        expect(server.name).to eq(:foo)
      end

      it "can not have children" do
        expect(server.allowed_node_types).to be_empty
      end

      describe "#fetch_command" do
        let(:server_command) { ServerCommand.explicit_command("echo") }

        before(:each) do
          server.config = ServerConfig.new(:commands => [server_command])
        end

        it "returns command by name if found" do
          expect(server.fetch_command("echo")).to eq(server_command)
        end

        it "returns explicit command if not found by name" do
          expect(server.fetch_command("shutdown -h now")).to eq(ServerCommand.explicit_command("shutdown -h now"))
        end
      end

      # check delegating to config
    end

  end
end

