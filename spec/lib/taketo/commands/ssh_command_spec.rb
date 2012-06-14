require File.expand_path('../../../../spec_helper', __FILE__)
require 'taketo/commands/ssh_command'

include Taketo::Commands

describe "SSH Command" do
  let(:environment) { stub(:Environment, :name => :staging) }
  let(:server) do
    stub(:Server, :name => :s1,
                  :host => "1.2.3.4", 
                  :port => 22,
                  :username => "deployer", 
                  :default_location => "/var/app",
                  :environment => environment,
                  :environment_variables => {})
  end

  let(:ssh_command) { SSHCommand.new(server) }

  it "should compose command based on provided server object" do
    ssh_command.render("bash").should == %q[ssh -t -p 22 deployer@1.2.3.4 "cd /var/app; RAILS_ENV=staging bash"]
  end

  it "should ignore absent parts" do
    server.stub(:port => nil)
    server.stub(:username => nil)
    ssh_command.render("bash").should == %q[ssh -t 1.2.3.4 "cd /var/app; RAILS_ENV=staging bash"]

    server.stub(:default_location => nil)
    ssh_command.render("bash").should == %q[ssh -t 1.2.3.4 "RAILS_ENV=staging bash"]
  end

  it "should require host" do
    server.stub(:host => nil)
    expect { ssh_command.render("bash") }.to raise_error ArgumentError, /host/
  end

  it "should have 'bash' as command default" do
    ssh_command.render.should =~ /bash/
  end

  it "should pass argv through to server" do
    ssh_command.render("bash", "TERM=xterm-256color").should =~ /TERM=xterm-256color.*bash/
    ssh_command.render("bash", ["LC_CTYPE=en_US.UTF-8", "TERM=xterm-256color"]).should =~ /LC_CTYPE=en_US.UTF-8 TERM=xterm-256color.*bash/
  end
end

