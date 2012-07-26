Feature: taketo config
  In order to get rid of routineous ssh command calls
  As a user
  I want to be able configure taketo

  Scenario: Shared server configs
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
      shared_server_config :shared_config_example do
        port 9999 #can contain any server config options
      end

      project :slots do
        environment :staging do
          server(:s1) { host "1.2.3.4"; include_shared_server_config(:shared_config_example) }
        end
      end
      """
    And I successfully run `taketo slots:staging:s1 --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the output should contain
      """
      ssh -t -p 9999 1.2.3.4 "RAILS_ENV=staging bash"
      """

  Scenario: Set environment variables
    When I have the following config in "/tmp/taketo_test_cfg.rb"
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
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the output should contain
      """
      RAILS_ENV=staging
      """
    And the output should contain
      """
      FOO=the\ value
      """
      
  Scenario: Reopen config scopes
    When I have the following config in "/tmp/taketo_test_cfg.rb"
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
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb slots:staging --dry-run`
    Then the output should match /ssh -t 1\.2\.3\.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/

  Scenario: Unique server alias
    When I have the following config in "/tmp/taketo_test_cfg.rb"
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
    And I successfully run `taketo ss2 --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the output should contain
      """
      ssh -t 2.3.4.5 "RAILS_ENV=staging bash"
      """

