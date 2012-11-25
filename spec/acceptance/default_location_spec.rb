require 'acceptance_spec_helper'

feature "Default location on remote host" do
  scenario "Set default location for server in config" do
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

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 1.2.3.4 "cd /var/foo; RAILS_ENV=staging bash"}
  end

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
    exit_status.should be_success
    stdout.should == %q{ssh -t 1.2.3.4 "cd /var/www; RAILS_ENV=staging bash"}
  end
end

