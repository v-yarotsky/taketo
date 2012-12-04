require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/environment'

include Taketo

describe "Environment" do
  subject(:environment) { Taketo::Constructs::Environment.new(:foo) }

  it "has name" do
    expect(environment.name).to eq(:foo)
  end

  it_behaves_like "a construct with nodes", :servers, :server

  specify "#project_name returns project name" do
    environment.parent = Taketo::Constructs::Project.new("TheProject")
    expect(environment.project_name).to eq("TheProject")
  end
end


