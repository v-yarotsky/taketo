require 'acceptance_spec_helper'

feature "Remote commands" do
  background { config_exists <<-CONFIG }
    project :slots do
      environment :staging do
        server do
          host "1.2.3.4"
          location "/var/apps/slots"
          command :console do
            execute "rails c"
          end
        end
      end
    end
  CONFIG

  scenario "Run command defined in config" do
    run "taketo slots:staging --dry-run --command console"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging rails c"}
  end

  scenario "Run explicit command on remote" do
    run "taketo --dry-run --command 'TERM=xterm-256color bash'"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging TERM=xterm-256color bash"}
  end
end

