require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/constructs/project'

include Taketo

describe "Project" do
  let(:project) { Taketo::Constructs::Project.new(:foo) }

  it "should have name" do
    project.name.should == :foo
  end

  describe "#append_environment" do
    it "should add an environment to project's environments collection" do
      environment = stub(:name => :foo)
      project.append_environment(environment)
      project.environments.should include(environment)
    end
  end

  describe "#find_environment" do
    it "should find environment by name" do
      project.environments.should_receive(:find_by_name).with(:foo).and_return(:bar)
      project.find_environment(:foo).should == :bar
    end
  end
end

