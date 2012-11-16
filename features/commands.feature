Feature:
  In order to be able to quickly run commands on my servers
  As a developer
  I want to have ability to create command shortcuts via config
  or specify command directly

  Background:
    When I have the following config
      """
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
      """

  Scenario: Run explicit command
    When I run taketo --dry-run --command "TERM=xterm-256color bash"
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging TERM=xterm-256color bash"
      """

  Scenario: Run command defined in config
    When I run taketo --dry-run --command console slots:staging
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging rails c"
      """

  Scenario: Override default location specified for server
    When I run taketo --dry-run --directory /var/www slots:staging
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/www; RAILS_ENV=staging bash"
      """
