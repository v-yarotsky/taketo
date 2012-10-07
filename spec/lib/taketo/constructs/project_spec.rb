require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/project'

include Taketo

describe "Project" do
  subject(:project) { Taketo::Constructs::Project.new(:foo) }

  it "has name" do
    expect(project.name).to eq(:foo)
  end
  
  specify "#append_environment sets project attribute on an environment to self" do
    environment = mock(:Environment, :name => :bar)
    environment.should_receive(:project=).with(project)
    project.append_environment(environment)
  end

  it_behaves_like "a construct with nodes", :environments, :environment
end

