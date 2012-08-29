require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/project'

include Taketo

describe "Project" do
  subject { Taketo::Constructs::Project.new(:foo) }

  it "should have name" do
    subject.name.should == :foo
  end
  
  specify "#append_environment should set project attribute on an environment to self" do
    environment = mock(:Environment, :name => :bar)
    environment.should_receive(:project=).with(subject)
    subject.append_environment(environment)
  end

  it_behaves_like "a construct with nodes", :environments, :environment
end

