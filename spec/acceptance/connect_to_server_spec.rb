require 'acceptance_spec_helper'

feature "connect to server" do
  scenario "reach server via ssh" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
            user "deployer"
            location "/var/apps/slots"
          end

          server :s2 do
            host "2.3.4.5"
          end
        end
      end
    CONFIG

    run "taketo slots:staging:s1 --dry-run"
    exit_status.should be_success
    stdout.should == %Q{ssh -t deployer@1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"}
  end

  scenario "ssh to the only server" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            location "/var/apps/slots"
          end
        end
      end
    CONFIG

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"}
  end

  scenario "ssh without password" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            identity_file "/home/gor/.ssh/foo bar"
            host "2.3.4.5"
          end
        end
      end
    CONFIG

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t -i /home/gor/.ssh/foo\ bar 2.3.4.5 "RAILS_ENV=staging bash"}
  end
end

