Feature:
  In order to be able to use the tool effectively
  As a user
  I want to view what's set up in config quickly

  Scenario: Config validation
    When I have the following config in "/tmp/taketo_test_cfg.rb"
    """
    project :foo do
      environment :bar do
        server do
          host "1.2.3.4"
          port 5678
          user "pivo"
          location "/var/apps/vodka"
          env :FRIENDS => "many", :TABLE => "round", :FOOD => "hot"
        end
      end
    end

    project :baz do
      environment :qux do
        server :bart do
          host "2.3.4.5"
          command :console do
            execute "something_to_execute"
          end
          command :killall do
            execute "killall humans"
          end
        end
      end
    end
    """
  And I run `taketo --config=/tmp/taketo_test_cfg.rb --list`
  Then the output should contain exactly:
    """
    Project: foo
      Environment: bar
        Server: default
          Host: 1.2.3.4
          Port: 5678
          User: pivo
          Default location: /var/apps/vodka
          Environment: FRIENDS=many TABLE=round FOOD=hot RAILS_ENV=bar
    
    Project: baz
      Environment: qux
        Server: bart
          Host: 2.3.4.5
          Environment: RAILS_ENV=qux
          Commands:
            console
            killall

    """
