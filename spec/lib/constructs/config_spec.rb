require File.expand_path('../../../spec_helper', __FILE__)
require 'taketo/constructs/config'

include Taketo

describe "Config" do
  let(:config) { Taketo::Constructs::Config.new }

  describe "#append_project" do
    it "should add project to config's projects collection" do
      project = stub(:name => :foo)
      config.append_project(project)
      config.projects[:foo].should == project
    end
  end
end

