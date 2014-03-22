require 'spec_helper'

module Taketo
  module Support

    describe ServerCommandRenderer do
      describe "#render" do
        let(:server_command) { "rails c" }
        let(:server) do
          double(:Server,
                :environment_variables => { :FOO => "bar baz" },
                :default_location => "/var/apps/the app")
        end

        it "picks up environment variables and location from server config" do
          renderer = described_class.new(server)
          expect(renderer.render(server_command)).to eq("cd /var/apps/the\\ app; FOO=bar\\ baz rails c")
        end

        it "lets user override default directory" do
          renderer = described_class.new(server, :directory => "/var/qux")
          expect(renderer.render(server_command)).to eq("cd /var/qux; FOO=bar\\ baz rails c")
        end
      end
    end

  end
end
