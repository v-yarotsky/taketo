require 'acceptance_spec_helper'

feature "Shared server config" do
  scenario "Simple shared server config" do
    create_config <<-CONFIG
      shared_server_config :sc1 do
        port 9999 #can contain any server config options
      end

      shared_server_config :sc2 do
        location "/var/qux"
      end

      project :slots do
        environment :staging do
          server(:s1) { host "1.2.3.4"; include_shared_server_config(:sc1, :sc2) }
        end
      end
    CONFIG

    run "taketo slots:staging:s1 --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"}
  end

  scenario "Shared server config with arguments" do
    create_config <<-CONFIG
      shared_server_config :sc_args1 do |port_num|
        port port_num
      end

      shared_server_config :sc_args2 do |projects_root_folder, project_folder|
        location File.join(projects_root_folder, project_folder)
      end

      project :slots do
        environment :staging do
          server(:s1) do
            host "1.2.3.4"
            include_shared_server_config(:sc_args1 => 9999, :sc_args2 => ['/var', 'qux'])
          end
        end
      end
    CONFIG

    run "taketo slots:staging:s1 --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"}
  end
end

