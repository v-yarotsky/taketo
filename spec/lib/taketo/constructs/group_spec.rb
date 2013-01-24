require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/group'

include Taketo

describe "Group" do
  subject(:group) { Taketo::Constructs::Group.new(:foo) }

  it "has name" do
    expect(group.name).to eq(:foo)
  end

  it_behaves_like "a construct with nodes", :servers, :server
end



