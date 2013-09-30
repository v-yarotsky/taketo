require 'spec_helper'

module Taketo::Constructs

  describe Config do
    subject(:config) { Config.new }

    it "allows only groups, projects and servers as children" do
      config.allowed_node_types.should =~ [:project, :group, :server]
    end

    it { should have_accessor(:default_destination) }
  end

end

