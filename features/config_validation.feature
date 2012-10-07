Feature:
  In order to be able to use the piece of software
  As a user
  I want to be guided if there are any errors in my configuration

  Scenario Outline: Config validation
    When I have the following config in "/tmp/taketo_test_cfg.rb"
    """
    <config>
    """
    And I run `taketo --config=/tmp/taketo_test_cfg.rb`
    Then the stderr should contain "<error>"

    Examples:
      | config                                           | error                                                                       |
      |                                                  | There are no projects. Add some to your config (~/.taketo.rc.rb by default) |
      | project(:foo) {}                                 | Project foo: no environments                                                |
      | project(:foo) { environment(:bar) {} }           | Environment foo:bar: no servers                                             |
      | project(:foo) { environment(:bar) { server {} }} | Server foo:bar:default: host is not defined                                 |

  Scenario: Global server alias clash
    When I have the following config in "/tmp/taketo_test_cfg.rb"
    """
    project(:foo) { environment(:bar) {
      server(:s1) { host '1.2.3.4'; global_alias :a1 }
      server(:s2) { host '2.3.4.5'; global_alias :a1 }
    }}
    """
    And I run `taketo --config=/tmp/taketo_test_cfg.rb`
    Then the stderr should contain "Server foo:bar:s2: global alias 'a1' has already been taken by server foo:bar:s1"

  Scenario: Bad command
    When I have the following config in "/tmp/taketo_test_cfg.rb"
    """
    project(:foo) { environment(:bar) {
      server(:s1) { host '1.2.3.4'
        command(:foo) {}
      }
    }}
    """
    And I run `taketo --config=/tmp/taketo_test_cfg.rb`
    Then the stderr should contain "Don't know what to execute on command foo"

