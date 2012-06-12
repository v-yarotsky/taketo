require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/constructs/environment'

include Taketo

describe "Environment" do
  let(:environment) { Taketo::Constructs::Environment.new(:foo) }

  it "should have name" do
    environment.name.should == :foo
  end

  describe "#append_server" do
    let(:server) { mock(:Server, :name => :foo).as_null_object }

    it "should add a server to environment's servers collection" do
      environment.append_server(server)
      environment.servers[:foo].should == server
    end

    it "should set environment attribute on a server to self" do
      server.should_receive(:environment=).with(environment)
      environment.append_server(server)
    end
  end
end


