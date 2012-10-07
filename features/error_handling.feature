Feature:
  To be able to troubleshoot my config issues quickly
  As a user
  I want to see meaningful errors when I accidentally specify bad location

  Background:
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
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
      """

  Scenario: Non-existent location
    And I run `taketo slots:staging:qqq --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the stderr should contain "server qqq not found for environment staging"

  Scenario: Ambiguous location
    And I run `taketo slots:staging --config=/tmp/taketo_test_cfg.rb --dry-run`
    Then the stderr should contain "There are multiple servers for environment staging: s1, s2"

