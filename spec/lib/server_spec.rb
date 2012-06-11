require File.expand_path('../../spec_helper', __FILE__)
require 'taketo/constructs/server'
require 'stringio'

include Taketo

describe "Server" do
  let(:server) { Taketo::Constructs::Server.new(:foo) }

  it "should have name" do
    server.name.should == :foo
  end

  it "should set host" do
    server.host = "foo"
    server.host.should == "foo"
  end

  it "should set port" do
    server.port = "foo"
    server.port.should == "foo"
  end

  it "should set username" do
    server.username = "foo"
    server.username.should == "foo"
  end

  it "should set default_location" do
    server.default_location = "foo"
    server.default_location.should == "foo"
  end
end


