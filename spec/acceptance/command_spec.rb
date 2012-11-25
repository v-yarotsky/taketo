require 'acceptance_spec_helper'

feature "Run explicit command on remote host" do
  scenario "Run explicit command on remote" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
          end
        end
      end
    CONFIG

    run "taketo --dry-run --command 'TERM=xterm-256color bash'"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 1.2.3.4 "RAILS_ENV=staging TERM=xterm-256color bash"}
  end
end

