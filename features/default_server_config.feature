Feature: taketo config's default server config
  In order to reduce duplication
  I want to be able set default configs for servers in particular scopes

  Background:
    When I have the following config
      """
      default_server_config do
        env :FOO => 'bar'
      end

      project :slots do
        default_server_config do
          location '/mnt/apps'
        end

        environment :staging do
          server :s1 do
            host "1.2.3.4"
          end
        end
      end

      project :shoes do
        environment :production do
          server do
            host "2.3.4.5"
          end
        end
      end
      """

  Scenario: Global default server config
    When I run taketo shoes --dry-run
    Then the output should match /ssh -t 2\.3\.4\.5 "(RAILS_ENV=production FOO=bar|FOO=bar RAILS_ENV=production) bash"/

  Scenario: Project default server config
    When I run taketo slots --dry-run
    Then the output should match /ssh -t 1\.2\.3\.4 "cd .mnt.apps; (RAILS_ENV=staging FOO=bar|FOO=bar RAILS_ENV=staging) bash"/

