require 'acceptance_spec_helper'

feature "Per-scope default server config" do
  background { config_exists <<-CONFIG }
      default_server_config do
        env :FOO => 'bar'
      end

      project :slots do
        default_server_config do
          location '/mnt/apps'
        end

        environment :staging do
          server :s1 do
            host "1.2.3.4"
          end
        end
      end

      project :shoes do
        environment :production do
          server do
            host "2.3.4.5"
          end
        end
      end
  CONFIG

  scenario "Global default server config" do
    run "taketo shoes --dry-run"
    exit_status.should be_success
    stdout.should =~ /ssh -t 2\.3\.4\.5 "(RAILS_ENV=production FOO=bar|FOO=bar RAILS_ENV=production) bash"/
  end

  scenario "Project default server config" do
    run "taketo slots --dry-run"
    stdout.should =~ /ssh -t 1\.2\.3\.4 "cd .mnt.apps; (RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/
  end
end

