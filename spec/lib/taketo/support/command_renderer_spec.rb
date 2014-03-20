require 'spec_helper'

module Taketo::Support

  describe CommandRenderer do
    describe "#render" do
      let(:server_config) do
        double(:ServerConfig,
               :environment_variables => { :FOO => "bar baz" },
               :default_location => "/var/apps/the_app")
      end

      it "picks up environment variables and location from server config" do
        pending
        command.command = "rails c"
        expect(command.render(server)).to eq("cd /var/apps/the\\ app; FOO=bar\\ baz rails c")
      end

      it "lets user override default directory" do
        pending
        command.command = "rails c"
        expect(command.render(server, :directory => "/var/qux")).to eq("cd /var/qux; FOO=bar\\ baz rails c")
      end
    end
  end
  
end
