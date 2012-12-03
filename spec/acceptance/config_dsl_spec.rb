require 'acceptance_spec_helper'

feature "Config DSL" do
  scenario "Reopen config scopes" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
          end
        end
      end

      project :slots do
        environment :staging do
          server do
            env :FOO => "bar"
          end
        end
      end
    CONFIG

    run "taketo slots:staging --dry-run"
    exit_status.should be_success
    stdout.should =~ %r{ssh -t 1.2.3.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"}
  end

  scenario "Command" do
    create_config <<-CONFIG
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

    run "taketo slots:staging --dry-run --command console"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging rails c"}
  end

  context "Default command" do
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

    scenario "Explicit default command" do
      run "taketo slots:staging:s1 --dry-run"
      exit_status.should be_success
      stdout.should == %q{ssh -t 1.2.3.4 "RAILS_ENV=staging rails c"}
    end

    scenario "Default command defined in config" do
      run "taketo slots:staging:s2 --dry-run"
      exit_status.should be_success
      stdout.should == %q{ssh -t 2.3.4.5 "RAILS_ENV=staging tmux attach || tmux new-session"}
    end
  end

  scenario "Default location on server" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            location '/var/foo'
            host "1.2.3.4"
          end
        end
      end
    CONFIG

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 1.2.3.4 "cd /var/foo; RAILS_ENV=staging bash"}
  end

  context "Per-Scope default server config" do
    background { config_exists <<-CONFIG }
        default_server_config do
          env :FOO => 'bar'
        end

        project :slots do
          default_server_config do
            location '/mnt/apps'
          end

          environment :staging do
            server :s1 do
              host "1.2.3.4"
            end
          end
        end

        project :shoes do
          environment :production do
            server do
              host "2.3.4.5"
            end
          end
        end
    CONFIG

    scenario "Global default server config" do
      run "taketo shoes --dry-run"
      exit_status.should be_success
      stdout.should =~ /ssh -t 2\.3\.4\.5 "(RAILS_ENV=production FOO=bar|FOO=bar RAILS_ENV=production) bash"/
    end

    scenario "Project default server config" do
      run "taketo slots --dry-run"
      stdout.should =~ /ssh -t 1\.2\.3\.4 "cd .mnt.apps; (RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/
    end
  end

  context "Shared server config" do
    scenario "Simple shared server config" do
      create_config <<-CONFIG
        shared_server_config :sc1 do
          port 9999 #can contain any server config options
        end

        shared_server_config :sc2 do
          location "/var/qux"
        end

        project :slots do
          environment :staging do
            server(:s1) { host "1.2.3.4"; include_shared_server_config(:sc1, :sc2) }
          end
        end
      CONFIG

      run "taketo slots:staging:s1 --dry-run"
      exit_status.should be_success
      stdout.should == %q{ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"}
    end

    scenario "Shared server config with arguments" do
      create_config <<-CONFIG
        shared_server_config :sc_args1 do |port_num|
          port port_num
        end

        shared_server_config :sc_args2 do |projects_root_folder, project_folder|
          location File.join(projects_root_folder, project_folder)
        end

        project :slots do
          environment :staging do
            server(:s1) do
              host "1.2.3.4"
              include_shared_server_config(:sc_args1 => 9999, :sc_args2 => ['/var', 'qux'])
            end
          end
        end
      CONFIG

      run "taketo slots:staging:s1 --dry-run"
      exit_status.should be_success
      stdout.should == %q{ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"}
    end
  end

  scenario "Environment variables" do
    create_config <<-CONFIG
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            location "/var/apps/slots"
            env :FOO => "the value"
          end
        end
      end
    CONFIG

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should =~ %r{ssh -t 1.2.3.4 "cd /var/apps/slots; (RAILS_ENV=staging FOO=the\\ value|FOO=the\\ value RAILS_ENV=staging) bash"}
  end

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

  scenario "Default destination" do
    create_config <<-CONFIG
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

    run "taketo --dry-run"
    exit_status.should be_success
    stdout.should == %Q{ssh -t 2.3.4.5 "RAILS_ENV=staging bash"}
  end

  scenario "ssh identity file" do
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

  scenario "server outside project" do
    create_config <<-CONFIG
      server :my_server do
        host "1.2.3.4"
      end
    CONFIG

    run "taketo my_server --dry-run"
    exit_status.should be_success
    stdout.should == %q{ssh -t 1.2.3.4 "bash"}
  end

end
