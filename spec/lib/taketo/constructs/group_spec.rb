require 'spec_helper'

module Taketo::Constructs

  describe Group do
    subject(:group) { Group.new(:foo) }

    it "has name" do
      expect(group.name).to eq(:foo)
    end

    describe "#rails_env" do
      it "returns parent's #rails_env" do
        group.parent = double(:Environment, :rails_env => "bar")
        expect(group.rails_env).to eq("bar")
      end

      it "does not fail if parent does not provide #rails_env" do
        group.parent = 1
        expect(group.rails_env).to eq(nil)
      end
    end

    it "allows only servers as children" do
      group.allowed_node_types.should =~ [:server]
    end
  end

end

