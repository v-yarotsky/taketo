require 'acceptance_spec_helper'

feature "Reopen config scopes" do
  scenario "Reopen config scopes" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
          end
        end
      end

      project :slots do
        environment :staging do
          server do
            env :FOO => "bar"
          end
        end
      end
    CONFIG

    run "taketo slots:staging --dry-run"
    exit_status.should be_success
    stdout.should =~ %r{ssh -t 1.2.3.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"}
  end
end

