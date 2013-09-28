require 'spec_helper'
require 'support/helpers/construct_spec_helper'

include Taketo

describe "Environment" do
  subject(:environment) { Taketo::Constructs::Environment.new(:foo) }

  it "has name" do
    expect(environment.name).to eq(:foo)
  end

  it_behaves_like "a construct with nodes", :groups, :group
  it_behaves_like "a node with servers"

  specify "#project_name returns project name" do
    environment.parent = Taketo::Constructs::Project.new("TheProject")
    expect(environment.project_name).to eq("TheProject")
  end

  specify "#rails_env returns name as string" do
    environment.rails_env.should == "foo"
  end
end


