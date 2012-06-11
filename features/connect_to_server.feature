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
        end
      end

      """
    And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run slots staging s1`
    Then the output should contain 'ssh -t "deployer"@"1.2.3.4" "cd \'/var/apps/slots\'; RAILS_ENV=staging bash"'
