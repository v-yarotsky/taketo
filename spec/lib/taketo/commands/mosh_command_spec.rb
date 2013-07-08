require 'spec_helper'
require 'taketo/commands'

include Taketo::Commands

describe "Mosh Command" do
  let(:server) do
    stub(:Server, :host => "1.2.3.4",
                  :port => 22,
                  :username => "deployer",
                  :identity_file => "/home/gor/.ssh/qqq")
  end

  subject(:mosh_command) { MoshCommand.new(server) }

  it "composes command based on provided server object" do
    mosh_command.render("foobar").should == %q[MOSH_TITLE_NOPREFIX=1 mosh --no-init --ssh="ssh -p 22 -i /home/gor/.ssh/qqq" -- deployer@1.2.3.4 /bin/sh -c "foobar"]
  end

  it "ignores absent parts if they are not required" do
    server.stub(:port => nil, :username => nil, :identity_file => nil)
    mosh_command.render("foobar").should == %q[MOSH_TITLE_NOPREFIX=1 mosh --no-init -- 1.2.3.4 /bin/sh -c "foobar"]
  end
end

