Feature: Default server command
  I want to be able to run a command on
  remote host automatically

  Background:
    When I have the following config
      """
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"

            default_command :console

            command :console do
              execute "rails c"
            end
          end

          server :s2 do
            host "2.3.4.5"

            default_command "tmux attach || tmux new-session"
          end
        end
      end
      """

  Scenario: Run command defined in config
    When I run taketo --dry-run slots:staging:s1
    Then the output should contain
      """
      ssh -t 1.2.3.4 "RAILS_ENV=staging rails c"
      """

  Scenario: Run explicit command
    When I run taketo --dry-run slots:staging:s2
    Then the output should contain
      """
      ssh -t 2.3.4.5 "RAILS_ENV=staging tmux attach || tmux new-session"
      """


