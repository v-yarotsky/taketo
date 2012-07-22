require File.expand_path('../../spec_helper', __FILE__)
require 'taketo/dsl'

describe "Taketo DSL" do
  it "should parse config and instantiate objects" do
    factory = Taketo::ConstructsFactory.new
    config = Taketo::DSL.new(factory).configure do
      project :slots do
        environment :staging do
          server do
            host "127.0.0.2"
            user "deployer"
            location "/var/app"
            env :FOO => "bar"
            command :console do
              execute "rails c"
            end
          end
        end

        environment :production do
          {
            :s1 => "127.0.0.3",
            :s2 => "127.0.0.4",
          }.each do |server_name, host_name|
            server server_name do
              host host_name
              location "/var/app"
            end
          end
        end
      end
    end

    config.projects.length.should == 1
    project = config.projects[:slots]
    project.name.should == :slots

    project.environments.length.should == 2
    staging = project.environments[:staging]
    
    staging.servers.length.should == 1
    staging_server = staging.servers[:default]
    staging_server.name.should == :default
    staging_server.host.should == "127.0.0.2"
    staging_server.username.should == "deployer"
    staging_server.default_location.should == "/var/app"
    staging_server.environment_variables.should == { :RAILS_ENV => "staging", :FOO => "bar" }
    staging_server.commands.length.should == 1
    staging_server.commands[:console].command.should == "rails c"

    production = project.environments[:production]
    production.servers.length.should == 2
  end
end

