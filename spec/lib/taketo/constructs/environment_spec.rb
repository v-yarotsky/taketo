require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/environment'

include Taketo

describe "Environment" do
  subject { Taketo::Constructs::Environment.new(:foo) }

  it "should have name" do
    subject.name.should == :foo
  end

  it_behaves_like "a construct with nodes", :servers, :server

  specify "#append_server should set environment attribute on a server to self" do
    server = mock(:Server, :name => :foo)
    server.should_receive(:environment=).with(subject)
    subject.append_server(server)
  end

  specify "#project_name should return project name" do
    subject.project = stub(:Project, :name => "TheProject")
    subject.project_name.should == "TheProject"
  end 
end


