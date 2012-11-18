Feature: Global server alias
  In order to save some keystrokes on typing
  fully qualified destination for frequently
  used servers, I want to be able to specify
  an aliases

  Scenario: Unique server alias
    When I have the following config
      """
      project :slots do
        environment :staging do
          server :s1 do
            host "1.2.3.4"
          end
          server :s2 do
            global_alias :ss2
            host "2.3.4.5"
          end
        end
      end
      """
    And I run taketo ss2 --dry-run
    Then the output should contain
      """
      ssh -t 2.3.4.5 "RAILS_ENV=staging bash"
      """


