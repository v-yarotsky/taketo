require 'spec_helper'

module Taketo
  module Constructs

    describe Group do
      subject(:group) { Group.new(:foo) }

      it "has name" do
        expect(group.name).to eq(:foo)
      end

      it "allows only servers as children" do
        group.allowed_node_types.should =~ [:server]
      end
    end

  end
end

