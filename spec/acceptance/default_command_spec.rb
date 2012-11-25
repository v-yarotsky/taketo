require 'acceptance_spec_helper'

feature "Default server command" do
  background { config_exists <<-CONFIG }
    project :slots do
      environment :staging do
        server :s1 do
          host "1.2.3.4"

          default_command :console

          command :console do
            execute "rails c"
          end
        end

        server :s2 do
          host "2.3.4.5"

          default_command "tmux attach || tmux new-session"
        end
      end
    end
  CONFIG

  scenario "Run explicit default command" do
    run "taketo slots:staging:s1 --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 1.2.3.4 "RAILS_ENV=staging rails c"}
  end

  scenario "Run default command defined in config" do
    run "taketo slots:staging:s2 --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 2.3.4.5 "RAILS_ENV=staging tmux attach || tmux new-session"}
  end
end

