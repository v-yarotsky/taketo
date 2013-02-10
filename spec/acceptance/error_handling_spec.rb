require 'acceptance_spec_helper'

feature "Resolve host error handling" do
  background { config_exists <<-CONFIG }
    default_destination "slots:staging:s2"
    project :slots do
      environment :staging do
        server :s1 do
          host "1.2.3.4"
        end

        server :s2 do
          host "2.3.4.5"
        end
      end
    end
  CONFIG

  scenario "Non-existent location" do
    run "taketo slots:staging:qqq --dry-run"
    stderr.should include("Can't find such destination: slots:staging:qqq")
    exit_status.should_not be_success
  end

  scenario "Ambiguous location" do
    run "taketo slots:staging --dry-run"
    stderr.should include("There are multiple possible destinations: slots:staging:s1, slots:staging:s2")
    exit_status.should_not be_success
  end
end

