require 'spec_helper'

module Taketo
  module ConfigVisitors

    describe SSHConfigGeneratorVisitor do
      subject(:generator) { SSHConfigGeneratorVisitor.new }

      describe "#visit_server" do
        let(:server) { double(:Server, :name => :sponge, :host => "bar.foo.com", :port => nil, :username => nil, :identity_file => nil, :global_alias => nil) }

        it "renders available server info" do
          server.stub(:port => 8000, :username => "bob", :identity_file => "path_to_identity_file")
          generator.visit_server(server)
          expect(generator.result).to include(<<-SSH.chomp)
Host bar.foo.com
Hostname bar.foo.com
Port 8000
User bob
IdentityFile path_to_identity_file
SSH
        end

        it "skips undefined options" do
          generator.visit_server(server)
          expect(generator.result).to include(<<-SSH.chomp)
Host bar.foo.com
Hostname bar.foo.com
SSH
        end

        it "prefers global alias as Hostname" do
          server.stub(:global_alias => "bazqux")
          generator.visit_server(server)
          expect(generator.result).to include(<<-SSH.chomp)
Host bazqux
Hostname bar.foo.com
SSH
        end
      end

      it "ignores non-server nodes" do
        expect { generator.visit(1) }.not_to raise_error
      end
    end

  end
end

