require 'acceptance_spec_helper'

feature "Config validation" do
  scenario "No servers defined" do
    create_config <<-CONFIG
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("There are no servers. Add some to your config (~/.taketo.rc.rb by default)")
  end

  scenario "Project has no environments" do
    create_config <<-CONFIG
      project :foo do
      end

      project :bar do
        environment :baz do
          server :qux do
            host '1.2.3.4'
          end
        end
      end
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("Project foo: no environments")
  end

  scenario "Environment has no servers" do
    create_config <<-CONFIG
      project :foo do
        environment :bar do
        end
      end

      project :bar do
        environment :baz do
          server :qux do
            host '1.2.3.4'
          end
        end
      end
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("Environment foo:bar: no servers")
  end

  scenario "Server has no host defined" do
    create_config <<-CONFIG
      project :foo do
        environment :bar do
          server do
          end
        end
      end
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("Server foo:bar:default: host is not defined")
  end

  scenario "Duplicate global server alias" do
    create_config <<-CONFIG
      project :foo do
        environment :bar do
          server :s1 do
            host "1.2.3.4"
            global_alias :a1
          end

          server :s2 do
            host "2.3.4.5"
            global_alias :a1
          end
        end
      end
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("Server foo:bar:s2: global alias 'a1' has already been taken by server foo:bar:s1")
  end

  scenario "Command without definition" do
    create_config <<-CONFIG
      project :foo do
        environment :bar do
          server do
            host "1.2.3.4"

            command :qux do
            end
          end
        end
      end
    CONFIG

    run "taketo"
    exit_status.should_not be_success
    stderr.should include("Don't know what to execute on command qux")
  end
end

