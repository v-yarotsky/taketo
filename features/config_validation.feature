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
      | config                                | error                                                                       |
      |                                       | There are no projects. Add some to your config (~/.taketo.rc.rb by default) |
      | project(:foo) {}                      | There is no environments for the following projects: foo                    |
      | project(:foo) { environment(:bar) {}} | There is no servers for the following environments in project foo: bar      |
