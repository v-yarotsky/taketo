require 'spec_helper'
require 'taketo/group_list_visitor'

include Taketo

describe "GroupListVisitor" do
  subject(:group_list) { GroupListVisitor.new }

  describe "#result" do
    it "outputs list of qualified server names" do
      server1 = stub(:Server, :path => "foo")
      server2 = stub(:Server, :path => "bar")
      group_list.visit_server(server1)
      group_list.visit_server(server2)
      group_list.result.should == "foo\nbar"
    end
  end
end


