require 'acceptance_spec_helper'

feature "Aids completion with matches" do
  scenario "Show matching servers" do
    create_config <<-CONFIG
      project :foo do
        server :s1 do
          host '1.2.3.4'
        end
      end

      server :s10 do
        host '2.3.4.5'
      end
    CONFIG

    run "taketo s1 --matches"
    exit_status.should be_success
    stdout.should =~ %r{(foo:s1 s10|s10 foo:s1)}
  end
end


