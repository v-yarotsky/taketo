require 'spec_helper'

module Taketo
  module Constructs

    describe Project do
      subject(:project) { Project.new(:foo) }

      it "has name" do
        expect(project.name).to eq(:foo)
      end

      it "allows only groups, environments and servers as children" do
        project.allowed_node_types.should =~ [:group, :environment, :server]
      end
    end

  end
end

