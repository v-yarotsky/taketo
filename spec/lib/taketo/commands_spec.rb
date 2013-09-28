require 'spec_helper'

include Taketo

describe "Commands" do
  describe ".[]" do
    it "returns class by name" do
      Commands[:mosh].should == Commands::MoshCommand
    end

    it "raises ArgumentError if command not found" do
      expect do
        Commands[:never_existed_here]
      end.to raise_error(Commands::CommandNotFoundError, /not found/i)
    end
  end
end

