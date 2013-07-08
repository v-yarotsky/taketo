require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs'

include Taketo

describe "Project" do
  subject(:project) { Taketo::Constructs::Project.new(:foo) }

  it "has name" do
    expect(project.name).to eq(:foo)
  end

  it_behaves_like "a construct with nodes", :environments, :environment
  it_behaves_like "a construct with nodes", :groups, :group
  it_behaves_like "a node with servers"
end

