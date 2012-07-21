Feature: 
  In order to be able to access my servers quickly
  As a developer
  I want to have a nifty little utility
  configurable with simple DSL

  Scenario: SSH to server
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
            user "deployer"
            location "/var/apps/slots"
          end

          server :s2 do
            host "2.3.4.5"
          end
        end
      end

      """
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run slots:staging:s1`
    Then the output should contain
      """
      ssh -t deployer@1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"
      """

  Scenario: SSH to the only server
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
            location "/var/apps/slots"
          end
        end
      end
      """
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"
      """

  Scenario: Set environment variables
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
      project :slots do
        environment :staging do
          server :s1 do
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
          server :s1 do
            host "1.2.3.4"
          end
        end
      end

      project :slots do
        environment :staging do
          server :s1 do
            env :FOO => "bar"
          end
        end
      end
      """
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb slots:staging:s1 --dry-run`
    Then the output should match /ssh -t 1\.2\.3\.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/

