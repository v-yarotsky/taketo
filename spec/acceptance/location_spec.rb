require 'acceptance_spec_helper'

feature "Location on remote host" do
  scenario "Override default location for server through --directory flag" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            location '/var/foo'
            host "1.2.3.4"
          end
        end
      end
    CONFIG

    run "taketo slots:staging --dry-run --directory /var/www"
    stdout.should == %q{ssh -t 1.2.3.4 "cd /var/www; RAILS_ENV=staging bash"}
    stderr.should be_empty
    exit_status.should be_success
  end
end

