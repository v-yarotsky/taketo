require 'acceptance_spec_helper'

feature "Environment variables on remote host" do
  scenario "Set default location for server in config" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            location "/var/apps/slots"
            env :FOO => "the value"
          end
        end
      end
    CONFIG

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should =~ %r{ssh -t 1.2.3.4 "cd /var/apps/slots; (RAILS_ENV=staging FOO=the\\ value|FOO=the\\ value RAILS_ENV=staging) bash"}
  end
end
