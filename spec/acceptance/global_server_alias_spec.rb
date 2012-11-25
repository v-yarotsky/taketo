require 'acceptance_spec_helper'

feature "Global server alias" do
  scenario "Unique server alias" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
          end

          server :s2 do
            global_alias :ss2
            host "2.3.4.5"
          end
        end
      end
    CONFIG

    run "taketo ss2 --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 2.3.4.5 "RAILS_ENV=staging bash"}
  end
end

