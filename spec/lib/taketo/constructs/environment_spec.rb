require 'spec_helper'

module Taketo::Constructs

  describe Environment do
    subject(:environment) { Environment.new(:foo) }

    it "has name" do
      expect(environment.name).to eq(:foo)
    end

    it "allows only groups and servers as children" do
      environment.allowed_node_types.should =~ [:group, :server]
    end

    specify "#project_name returns project name" do
      environment.parent = Project.new("TheProject")
      expect(environment.project_name).to eq("TheProject")
    end

    specify "#rails_env returns name as string" do
      environment.rails_env.should == "foo"
    end
  end

end

