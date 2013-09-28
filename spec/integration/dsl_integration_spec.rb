require 'spec_helper'

describe "Taketo DSL" do
  it "parses config and instantiate objects" do
    factory = Taketo::ConstructsFactory.new
    config = Taketo::DSL.new(factory).configure do
      shared_server_config(:commands) do
        command :console do
          execute "rails c"
          desc "Rails console"
        end
      end

      project :slots do
        environment :staging do
          server do
            host "127.0.0.2"
            user "deployer"
            location "/var/app"
            env :FOO => "bar"
            include_shared_server_config :commands
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
              include_shared_server_config :commands
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

    production = project.environments[:production]
    production.servers.length.should == 2
    production_server_1, production_server_2 = production.servers.first, production.servers.last

    [staging_server, production_server_1, production_server_2].each do |s|
      s.commands.length.should == 1
      s.commands[:console].command.should == "rails c"
    end
  end
end

