require File.expand_path('../../../../spec_helper', __FILE__)
require 'support/helpers/construct_spec_helper'
require 'taketo/constructs/config'

include Taketo

describe "Config" do
  subject { Taketo::Constructs::Config.new }

  it_behaves_like "a construct with nodes", :projects, :project

  it { should have_accessor(:default_destination) }
end

