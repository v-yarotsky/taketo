require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/project'

include Taketo

describe "Project" do
  subject { Taketo::Constructs::Project.new(:foo) }

  it "should have name" do
    subject.name.should == :foo
  end
  
  it_behaves_like "a construct with nodes", :environments, :environment
end

