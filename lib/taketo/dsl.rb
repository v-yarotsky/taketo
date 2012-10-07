require 'taketo/constructs_factory'

module Taketo
  class DSL
    class ScopeError < StandardError;  end
    class ConfigError < StandardError; end

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

      def define_method_in_scope(name, parent_scope, &block)
        define_method name do |*args, &blk|
          unless current_scope?(parent_scope)
            raise ScopeError,
              "#{name} can't be defined in #{current_scope} scope"
          end
          args.push blk if blk
          instance_exec(*args, &block)
        end
      end
    end

    attr_reader :current_scope_object, :config, :shared_server_configs

    def initialize(factory = Taketo::ConstructsFactory.new)
      @factory = factory
      @scope = [:config]
      @config = @current_scope_object = factory.create_config
      @shared_server_configs = Hash.new { |h, k| raise ConfigError, "Shared server config '#{k}' is not defined!"}
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

    define_method_in_scope(:default_destination, :config) { |destination|   current_scope_object.default_destination = destination }
    define_method_in_scope(:host, :server)                { |hostname|      current_scope_object.host = hostname                   }
    define_method_in_scope(:port, :server)                { |port_number|   current_scope_object.port = port_number                }
    define_method_in_scope(:user, :server)                { |username|      current_scope_object.username = username               }
    define_method_in_scope(:location, :server)            { |path|          current_scope_object.default_location = path           }
    define_method_in_scope(:global_alias,:server)         { |alias_name|    current_scope_object.global_alias = alias_name         }
    define_method_in_scope(:env, :server)                 { |env|           current_scope_object.env(env)                          }
    define_method_in_scope(:identity_file, :server)       { |identity_file| current_scope_object.identity_file = identity_file     }
    define_method_in_scope(:execute, :command)            { |command|       current_scope_object.command = command                 }
    define_method_in_scope(:desc, :command)               { |description|   current_scope_object.description = description         }

    define_method_in_scope(:shared_server_config, :config) do |name, blk|
      @shared_server_configs.store(name.to_sym, blk)
    end

    define_method_in_scope(:include_shared_server_config, :server) do |*args|
      if args.first.is_a?(Hash)
        configs_and_arguments = args.shift
        configs_and_arguments.each do |config_name, arguments|
          instance_exec(*arguments, &shared_server_configs[config_name])
        end
      else
        args.each do |config_name|
          instance_exec(&shared_server_configs[config_name])
        end
      end
    end
    alias :include_shared_server_configs :include_shared_server_config


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

