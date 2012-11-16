Feature:
  In order to be able to access my servers quickly
  As a developer
  I want to have a nifty little utility
  configurable with simple DSL

  Scenario: SSH to server
    When I have the following config
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
    And I run taketo --dry-run slots:staging:s1
    Then the output should contain
      """
      ssh -t deployer@1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"
      """

  Scenario: SSH to the only server
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            host "1.2.3.4"
            location "/var/apps/slots"
          end
        end
      end
      """
    And I run taketo --dry-run
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging bash"
      """

  Scenario: Default destination
    When I have the following config
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
    And I run taketo --dry-run
    Then the output should contain
      """
      ssh -t 2.3.4.5 "RAILS_ENV=staging bash"
      """

  Scenario: SSH key file
    When I have the following config
      """
      project :slots do
        environment :staging do
          server do
            identity_file "/home/gor/.ssh/foo bar"
            host "2.3.4.5"
          end
        end
      end
      """
    And I run taketo --dry-run
    Then the output should contain
      """
      ssh -t -i /home/gor/.ssh/foo\ bar 2.3.4.5 "RAILS_ENV=staging bash"
      """

