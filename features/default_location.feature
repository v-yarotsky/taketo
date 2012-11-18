Feature: Default location on remote host
  I want to be able to change directory on
  remote host automatically

  Scenario: Set default location for server in config
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
    When I run taketo --dry-run
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/foo; RAILS_ENV=staging bash"
      """

  Scenario: Override default location for server through command line
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

