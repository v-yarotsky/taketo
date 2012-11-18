Feature: Set environment variables
  I want to set neccessary environment variables on
  remote host automatically

  Scenario: Set environment variables in config
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


