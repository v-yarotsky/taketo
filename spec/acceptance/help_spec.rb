require 'acceptance_spec_helper'

feature "Global server alias" do
  background { config_exists <<-CONFIG }
    project :foo do
      environment :bar do
        server do
          host "1.2.3.4"
          port 5678
          user "pivo"
          location "/var/apps/vodka"
        end
      end
    end

    project :baz do
      environment :qux do
        server :bart do
          host "2.3.4.5"
          default_command :console
          command :console do
            execute "rails c"
          end
          command :killall do
            execute "killall humans"
            desc "Kill ALL humans"
          end
        end
      end
    end
  CONFIG

  scenario "Unique server alias" do
    run "taketo --view"
    exit_status.should be_success
    stdout.should == <<-CONFIG_OUTLINE.chomp

Project: foo
  Environment: bar
    Server: default
      Host: 1.2.3.4
      Port: 5678
      User: pivo
      Default location: /var/apps/vodka
      Default command: bash
      Environment: RAILS_ENV=bar

Project: baz
  Environment: qux
    Server: bart
      Host: 2.3.4.5
      Default command: rails c
      Environment: RAILS_ENV=qux
      Commands:
        console
        killall - Kill ALL humans
    CONFIG_OUTLINE
  end

  scenario "View particular server config" do
    run "taketo foo:bar:default --view"
    exit_status.should be_success
    stdout.should == <<-CONFIG_OUTLINE.chomp
Server: default
  Host: 1.2.3.4
  Port: 5678
  User: pivo
  Default location: /var/apps/vodka
  Default command: bash
  Environment: RAILS_ENV=bar
    CONFIG_OUTLINE
  end
end

