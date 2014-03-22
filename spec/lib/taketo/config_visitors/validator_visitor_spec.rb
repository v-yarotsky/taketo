require 'spec_helper'
require 'support/helpers/construct_spec_helper'

module Taketo
  module ConfigVisitors

    describe ValidatorVisitor do
      include ConstructsFixtures

      subject(:visitor) { ValidatorVisitor.new }

      { :Config => nil, :Project => "my_project", :Group => "my_group" }.each do |node_type, path|
        it "requires #{node_type} to have servers" do
          node = double(node_type, :path => path)
          expect(visitor).to receive(:node_has_servers?).and_return(false)
          error_message = /#{path ? path + ": " : ""}no servers/
          expect { visitor.send("visit_#{node_type.to_s.downcase}", node) }.to raise_error ConfigError, error_message

          # TODO refactor
          expect(visitor).to receive(:node_has_servers?).and_return(true)
          expect { visitor.send("visit_#{node_type.to_s.downcase}", node) }.not_to raise_error
        end
      end

      it "requires environments to have servers" do
        environment = double(:Environment, :path => "my_project:my_environment")
        expect(visitor).to receive(:node_has_servers?).and_return(false)
        error_message = /my_project:my_environment: no servers/
        expect { visitor.visit_environment(environment) }.to raise_error ConfigError, error_message

        expect(visitor).to receive(:node_has_servers?).and_return(true)
        expect { visitor.visit_environment(environment) }.not_to raise_error
      end

      it "requires servers to have host" do
        server = server(:Server, :host => '', :path => "my_project:my_environment:my_server", :global_alias => nil)
        error_message = /my_project:my_environment:my_server: host is not defined/
        expect { visitor.visit_server(server) }.to raise_error ConfigError, error_message

        server.stub(:host => 'the-host')
        expect { visitor.visit_server(server) }.not_to raise_error
      end

      it "requires servers to have unique global server aliases" do
        server1 = server(:Server, :host => 'the-host1', :path => "my_project:my_environment:my_server", :global_alias => 'foo')
        server2 = server(:Server, :host => 'the-host2', :path => "my_project:my_environment2:my_server3", :global_alias => 'foo')
        error_message = /my_project:my_environment2:my_server3: global alias 'foo' has already been taken.*my_project:my_environment:my_server/
        @visitor = visitor
        expect { @visitor.visit_server(server1) }.not_to raise_error
        expect { @visitor.visit_server(server2) }.to raise_error ConfigError, error_message
      end

      it "requires server commands to be configured" do
        server_foo = server(:foo, :host => "the-host-1", :path => "p:e:foo", :global_alias => "foo") do |s|
          s.config.add_command(server_command("fox"))
        end
        error_message = /execute/
        @visitor = visitor
        expect { @visitor.visit_server(server_foo) }.to raise_error ConfigError, error_message
      end
    end

  end
end

