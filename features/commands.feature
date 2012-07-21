Feature: 
  In order to be able to quickly run commands on my servers
  As a developer
  I want to have ability to create command shortcuts via config
  or specify command directly

  Scenario: Run explicit command
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
      And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run --command "TERM=xterm-256color bash" slots staging s1`
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging TERM=xterm-256color bash"
      """

  Scenario: Run command defined in config
    When I have the following config in "/tmp/taketo_test_cfg.rb"
      """
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
            location "/var/apps/slots"
            command :console do
              execute "rails c"
            end
          end
        end
      end
      """
      And I successfully run `taketo --config=/tmp/taketo_test_cfg.rb --dry-run --command console slots staging s1`
    Then the output should contain
      """
      ssh -t 1.2.3.4 "cd /var/apps/slots; RAILS_ENV=staging rails c"
      """

