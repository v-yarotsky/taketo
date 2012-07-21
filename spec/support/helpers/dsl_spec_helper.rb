module DSLSpec
  class TestConstructsFactory
    attr_reader :config, :project, :environment, :server, :command

    def create(type, *args)
      send("create_#{type}", *args)
    end

    def create_config(*args)
      @config ||= RSpec::Mocks::Mock.new(:Config).as_null_object
    end

    def create_project(name = :foo)
      @project ||= RSpec::Mocks::Mock.new(:Project, :name => name).as_null_object
    end

    def create_environment(name = :foo)
      @environment ||= RSpec::Mocks::Mock.new(:Environment, :name => name).as_null_object
    end

    def create_server(name = :foo)
      @server ||= RSpec::Mocks::Mock.new(:Server, :name => name).as_null_object
    end

    def create_command(name = :the_cmd)
      @command ||= RSpec::Mocks::Mock.new(:Command, :name => name).as_null_object
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

  def dsl(scope = [:config], scope_object = nil)
    context = DSL.new(factory)

    def context.set_scope(s, obj)
      @scope = s
      @current_scope_object = obj
    end

    context.set_scope(scope, scope_object || factory.create_config)

    yield context
  end

  def scopes
    scopes_hash = {
      :config      => [:config],
      :project     => [:config, :project],
      :environment => [:config, :project, :environment],
      :server      => [:config, :project, :environment, :server],
      :command     => [:config, :project, :environment, :server, :command]
    }

    def scopes_hash.except(*keys)
      self.values_at(*(self.keys - keys))
    end

    scopes_hash
  end
end
