Feature: taketo config
  In order to get rid of routineous ssh command calls
  As a user
  I want to be able configure taketo

  Scenario: Shared server configs
    When I have the following config
      """
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
      """
    And I run taketo slots:staging:s1 --dry-run
    Then the output should contain
      """
      ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"
      """

  Scenario: Shared server configs with arguments
    When I have the following config
      """
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
      """
    And I run taketo slots:staging:s1 --dry-run
    Then the output should contain
      """
      ssh -t -p 9999 1.2.3.4 "cd /var/qux; RAILS_ENV=staging bash"
      """

  Scenario: Set environment variables
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            location "/var/apps/slots"
            env :FOO => "the value"
          end
        end
      end
      """
    And I run taketo --dry-run
    Then the output should contain
      """
      RAILS_ENV=staging
      """
    And the output should contain
      """
      FOO=the\ value
      """

  Scenario: Reopen config scopes
    When I have the following config
      """
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
      """
    And I run taketo slots:staging --dry-run
    Then the output should match /ssh -t 1\.2\.3\.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/

  Scenario: Unique server alias
    When I have the following config
      """
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
      """
    And I run taketo ss2 --dry-run
    Then the output should contain
      """
      ssh -t 2.3.4.5 "RAILS_ENV=staging bash"
      """

  Scenario: Override default location specified for server
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            location '/var/foo'
            host "1.2.3.4"
          end
        end
      end
      """
    When I run taketo --dry-run --directory /var/www slots:staging
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/www; RAILS_ENV=staging bash"
      """

  Scenario: Default server command
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"

            default_command :tmux

            command :tmux do
              execute "tmux attach || tmux new-session"
            end
          end
        end
      end
      """
    When I run taketo --dry-run slots:staging
    Then the output should contain
      """
      ssh -t 1.2.3.4 "RAILS_ENV=staging tmux attach || tmux new-session"
      """
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            default_command "do_something"
          end
        end
      end
      """
    When I run taketo --dry-run slots:staging
    Then the output should contain
      """
      ssh -t 1.2.3.4 "RAILS_ENV=staging do_something"
      """

