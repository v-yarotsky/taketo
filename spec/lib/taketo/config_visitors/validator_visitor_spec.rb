require 'spec_helper'
require 'taketo/config_visitors'

module Taketo::ConfigVisitors

  describe ValidatorVisitor do
    subject(:visitor) { ValidatorVisitor.new }

    { :Config => nil, :Project => "my_project", :Group => "my_group" }.each do |node_type, path|
      it "requires #{node_type} to have servers" do
        node = stub(node_type, :has_servers? => false, :path => path)
        error_message = /#{path ? path + ": " : ""}no servers/
        expect { visitor.send("visit_#{node_type.to_s.downcase}", node) }.to raise_error ConfigError, error_message

        node.stub(:has_servers? => true)
        expect { visitor.send("visit_#{node_type.to_s.downcase}", node) }.not_to raise_error ConfigError, error_message
      end
    end

    it "requires environments to have servers" do
      environment = stub(:Environment, :has_servers? => false, :path => "my_project:my_environment")
      error_message = /my_project:my_environment: no servers/
      expect { visitor.visit_environment(environment) }.to raise_error ConfigError, error_message

      environment.stub(:has_servers? => true)
      expect { visitor.visit_environment(environment) }.not_to raise_error ConfigError, error_message
    end

    it "requires servers to have host" do
      server = stub(:Server, :host => '', :path => "my_project:my_environment:my_server", :global_alias => nil)
      error_message = /my_project:my_environment:my_server: host is not defined/
      expect { visitor.visit_server(server) }.to raise_error ConfigError, error_message

      server.stub(:host => 'the-host')
      expect { visitor.visit_server(server) }.not_to raise_error ConfigError, error_message
    end

    it "requires servers to have unique global server aliases" do
      server1 = stub(:Server, :host => 'the-host1', :path => "my_project:my_environment:my_server", :global_alias => 'foo')
      server2 = stub(:Server, :host => 'the-host2', :path => "my_project:my_environment2:my_server3", :global_alias => 'foo')
      error_message = /my_project:my_environment2:my_server3: global alias 'foo' has already been taken.*my_project:my_environment:my_server/
      @visitor = visitor
      expect { @visitor.visit_server(server1) }.not_to raise_error ConfigError, error_message
      expect { @visitor.visit_server(server2) }.to raise_error ConfigError, error_message
    end

    it "requires commands to have command specified" do
      command = stub(:Command, :command => '', :name => 'qux')
      error_message = /execute/
      expect { visitor.visit_command(command) }.to raise_error ConfigError, error_message
      command.stub(:command => 'foo')
      expect { visitor.visit_command(command) }.not_to raise_error ConfigError, error_message
    end
  end

end

