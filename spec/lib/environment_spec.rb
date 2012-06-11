require File.expand_path('../../spec_helper', __FILE__)
require 'taketo/constructs/environment'

include Taketo

describe "Environment" do
  let(:environment) { Taketo::Constructs::Environment.new(:foo) }

  it "should have name" do
    environment.name.should == :foo
  end

  describe "#append_server" do
    it "should add a server to environment's servers collection" do
      server = stub(:name => :foo)
      environment.append_server(server)
      environment.servers[:foo].should == server
    end
  end
end


