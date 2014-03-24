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
          server.add_command(server_command)
        end

        it "returns command by name if found" do
          expect(server.fetch_command("echo")).to eq(server_command)
        end

        it "returns explicit command if not found by name" do
          expect(server.fetch_command("shutdown -h now")).to eq(ServerCommand.explicit_command("shutdown -h now"))
        end
      end

      it { should have_accessor(:host) }
      it { should have_accessor(:port) }
      it { should have_accessor(:global_alias, "str") }
      it { should have_accessor(:username) }
      it { should have_accessor(:identity_file) }
      it { should have_accessor(:ssh_command) }
      it { should have_accessor(:default_location) }
      it { should have_accessor(:default_command) }

      it { should respond_to(:environment_variables) }
      it { should respond_to(:commands) }
      it { should respond_to(:add_environment_variables) }
      it { should respond_to(:add_command) }
      it { should respond_to(:include_shared_server_config) }
    end

  end
end

