require 'acceptance_spec_helper'

feature "Aids completion with matches" do
  background { config_exists <<-CONFIG }
    project :foo do
      environment :test do
        server :s1 do
          host '1.2.3.4'
        end
      end
    end

    server :s10 do
      host '2.3.4.5'
    end
  CONFIG

  scenario "Show servers by default" do
    run "taketo --matches"
    stdout.split.should =~ %w(foo:test:s1 s10)
    stderr.should be_empty
    exit_status.should be_success
  end

  scenario "Show scopes for --list" do
    run "taketo --list --matches"
    stdout.split.should =~ %w(foo foo:test)
    stderr.should be_empty
    exit_status.should be_success
  end

  scenario "Show all for --view" do
    run "taketo --view --matches"
    stdout.split.should =~ %w(foo foo:test foo:test:s1 s10)
    stderr.should be_empty
    exit_status.should be_success
  end
end


