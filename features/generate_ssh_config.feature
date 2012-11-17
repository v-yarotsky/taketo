Feature:
  In order to eliminate duplication between taketo config and ssh config
  As a user
  I want to be able to convert taketo config to ssh config

  Background:
    When I have the following config
    """
    project :foo do
      environment :bar do
        server do
          host "bar.foo.com"
          port 5678
          user "pivo"
          identity_file "~/.ssh/id_rsa"
        end
      end
    end

    project :baz do
      environment :qux do
        server :bart do
          global_alias :bazqux
          host "2.3.4.5"
        end
      end
    end
    """

  Scenario: Generate ssh config
    When I run taketo --generate-ssh-config
    Then the output should contain exactly:
      """
      Host bar.foo.com
      Hostname bar.foo.com
      Port 5678
      User pivo
      IdentityFile ~/.ssh/id_rsa

      Host bazqux
      Hostname 2.3.4.5

      """

