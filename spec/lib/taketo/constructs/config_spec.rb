require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/config'

include Taketo

describe "Config" do
  let(:config) { Taketo::Constructs::Config.new }

  describe "#append_project" do
    it "should add project to config's projects collection" do
      project = stub(:name => :foo)
      config.append_project(project)
      config.projects.should include(project)
    end
  end

  describe "#find_project" do
    it "should find project by name" do
      config.projects.should_receive(:find_by_name).with(:foo).and_return(:bar)
      config.find_project(:foo).should == :bar
    end
  end
end

