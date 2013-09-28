module DSLSpec
  class TestConstructsFactory
    attr_reader :config, :project, :environment, :server, :group, :command

    def create(type, *args)
      send("create_#{type}", *args)
    end

    def create_config(*args)
      @config ||= RSpec::Mocks::Mock.new(:Config, :default_server_config => proc {}).as_null_object
    end

    def create_project(name = :foo)
      @project ||= RSpec::Mocks::Mock.new(:Project, :name => name, :default_server_config => proc {}).as_null_object
    end

    def create_environment(name = :foo)
      @environment ||= RSpec::Mocks::Mock.new(:Environment, :name => name, :default_server_config => proc {}).as_null_object
    end

    def create_server(name = :foo)
      @server ||= RSpec::Mocks::Mock.new(:Server, :name => name, :default_server_config => proc {}).as_null_object
    end

    def create_group(name = :foo)
      @group ||= RSpec::Mocks::Mock.new(:Group, :name => name, :default_server_config => proc {}).as_null_object
    end

    def create_command(name = :the_cmd)
      @command ||= RSpec::Mocks::Mock.new(:Command, :name => name, :default_server_config => proc {}).as_null_object
    end
  end

  def factory
    @factory ||= TestConstructsFactory.new
  end

  RSpec.configure do |config|
    config.after(:each) do
      @factory = nil
    end
  end

  def dsl(scope = scopes[:config], scope_object = nil, &block)
    context = Taketo::DSL.new(factory)

    def context.set_scope(s, obj)
      @scope = s
      @current_scope_object = obj
    end

    context.set_scope(scope, scope_object || factory.create_config)
    block.call(context)
  end

  def scopes
    scopes_hash = {
      :config      => [[:config]],
      :project     => [[:config, :project]],
      :environment => [[:config, :project, :environment]],
      :group       => [
        [:config, :group],
        [:config, :project, :group],
        [:config, :project, :environment, :group]
      ],
      :server      => [
        # [:config, :server],
        # [:config, :group, :server],
        # [:config, :project, :server],
        # [:config, :project, :group, :server],
        # [:config, :project, :environment, :server],
        [:config, :project, :environment, :group, :server]
      ],
      :command     => [
        [:config, :server, :command],
        [:config, :group, :server, :command],
        [:config, :project, :server, :command],
        [:config, :project, :group, :server, :command],
        [:config, :project, :environment, :server, :command],
        [:config, :project, :environment, :group, :server, :command]
      ]
    }

    def scopes_hash.except(*keys)
      self.values_at(*(self.keys - keys))
    end

    scopes_hash
  end
end
