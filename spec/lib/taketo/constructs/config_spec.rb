require 'spec_helper'
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/config'

include Taketo

describe "Config" do
  subject(:config) { Taketo::Constructs::Config.new }

  it_behaves_like "a construct with nodes", :groups, :group
  it_behaves_like "a construct with nodes", :projects, :project

  it { should have_accessor(:default_destination) }

  it_behaves_like "a node with servers", :servers, :server
end

