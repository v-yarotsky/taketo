require 'taketo/constructs_factory'

module Taketo
  class DSL
    class ScopeError < StandardError; end

    class << self
      def define_scope(scope, parent_scope, options = {})
        define_method scope do |*args, &block|
          unless current_scope?(parent_scope)
            raise ScopeError,
              "#{scope} can't be defined in #{current_scope} scope"
          end
          name = args.shift || options[:default_name] or raise(ArgumentError, "Name not specified")
          scope_object = current_scope_object.find(scope, name) { @factory.create(scope, name) }
          in_scope(scope, scope_object) do
            block.call
          end
        end
      end

      def define_attribute(name, parent_scope, &block)
        define_method name do |attribute|
          unless current_scope?(parent_scope)
            raise ScopeError,
              "#{name} can't be defined in #{current_scope} scope"
          end
          instance_exec(attribute, &block)
        end
      end
    end

    attr_reader :current_scope_object, :config

    def initialize(factory = Taketo::ConstructsFactory.new)
      @factory = factory
      @scope = [:config]
      @config = @current_scope_object = factory.create_config
    end

    def configure(filename = nil, &block)
      if filename
        filename = filename.to_s
        config_text = File.read(filename)
        instance_eval config_text, filename, 1
      elsif block
        instance_eval(&block)
      else
        raise ArgumentError, "Either filename or block should be provided"
      end
      @config
    end

    define_scope :project, :config
    define_scope :environment, :project
    define_scope :server, :environment, :default_name => :default
    define_scope :command, :server

    define_attribute(:default_destination, :config) { |destination| current_scope_object.default_destination = destination }
    define_attribute(:host, :server)                { |hostname|    current_scope_object.host = hostname                   }
    define_attribute(:port, :server)                { |port_number| current_scope_object.port = port_number                }
    define_attribute(:user, :server)                { |username|    current_scope_object.username = username               }
    define_attribute(:location, :server)            { |path|        current_scope_object.default_location = path           }
    define_attribute(:env, :server)                 { |env|         current_scope_object.env(env)                          }
    define_attribute(:execute, :command)            { |command|     current_scope_object.command = command                 }

    private

    def current_scope
      @scope.last
    end

    def current_scope?(scope)
      current_scope == scope
    end

    [:config, :project, :environment, :server, :command].each do |scope|
      define_method("#{scope}_scope?") { current_scope == scope }
    end

    def in_scope(scope, new_scope_object)
      parent_scope_object, @current_scope_object = @current_scope_object, new_scope_object
      @scope.push(scope)
      yield
      parent_scope_object.send("append_#{scope}", current_scope_object)
      @scope.pop
      @current_scope_object = parent_scope_object
    end

  end
end

