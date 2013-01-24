require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/project'

include Taketo

describe "Project" do
  subject(:project) { Taketo::Constructs::Project.new(:foo) }

  it "has name" do
    expect(project.name).to eq(:foo)
  end

  it_behaves_like "a construct with nodes", :environments, :environment
  it_behaves_like "a construct with nodes", :servers, :server
  it_behaves_like "a construct with nodes", :groups, :group

  describe "#has_servers?" do
    it "takes nested servers into account"
  end
end

