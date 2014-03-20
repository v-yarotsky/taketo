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

    specify "#global_alias= converts to string" do
      server.global_alias = :foo
      expect(server.global_alias).to eq("foo")
    end

    # check delegating to config
  end

end

