require 'spec_helper'

include Taketo

describe "Actions" do
  describe ".[]" do
    it "returns class by name" do
      Actions[:matches].should == Actions::Matches
    end

    it "returns LoginAction if action was not found" do
      Actions[:never_existed_here].should == Actions::Login
    end
  end
end

