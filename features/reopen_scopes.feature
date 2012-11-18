Feature: Remove config scopes
  In order to amend configuration
  I want to be able to reopen scopes

  Scenario: Reopen config scopes
    When I have the following config
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
    And I run taketo slots:staging --dry-run
    Then the output should match /ssh -t 1\.2\.3\.4 "(RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/

