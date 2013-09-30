require 'spec_helper'

module Taketo::ConfigVisitors

  describe GroupListVisitor do
    subject(:group_list) { GroupListVisitor.new }

    describe "#result" do
      it "outputs list of qualified server names" do
        server1 = double(:Server, :path => "foo")
        server2 = double(:Server, :path => "bar")
        group_list.visit_server(server1)
        group_list.visit_server(server2)
        group_list.result.should == "foo\nbar"
      end
    end
  end

end

