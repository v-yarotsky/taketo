require 'taketo/constructs_factory'

module Taketo
  class DSL
    class ScopeError  < StandardError; end
    class ConfigError < StandardError; end

    class << self
      def define_scope(scope, *parent_scopes_and_options, &block)
        options = parent_scopes_and_options.last.is_a?(Hash) ? parent_scopes_and_options.pop : {}
        parent_scopes = parent_scopes_and_options

        define_method scope do |*args, &blk|
          ensure_nesting_allowed!(scope, parent_scopes)
          name = args.shift || options[:default_name] or raise(ArgumentError, "Name not specified")

          scope_object = current_scope_object.find(scope, name) { @factory.create(scope, name) }

          in_scope(scope, scope_object) do
            instance_exec(current_scope_object, &block) if block
            blk.call
          end
        end

        define_method("#{scope}_scope?") do
          current_scope == scope
        end
      end

      def define_method_in_scope(name, *parent_scopes, &block)
        define_method name do |*args, &blk|
          ensure_nesting_allowed!(name, parent_scopes)
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
    define_scope :group, :environment, :project, :config

    define_scope :server, :environment, :project, :config, :group, :default_name => :default do |s|
      instance_eval(&s.default_server_config)
    end

    define_scope :command, :server

    define_method_in_scope(:default_destination, :config) { |destination|   current_scope_object.default_destination = destination }
    define_method_in_scope(:host, :server)                { |hostname|      current_scope_object.host = hostname                   }
    define_method_in_scope(:port, :server)                { |port_number|   current_scope_object.port = port_number                }
    define_method_in_scope(:user, :server)                { |username|      current_scope_object.username = username               }
    define_method_in_scope(:location, :server)            { |path|          current_scope_object.default_location = path           }
    define_method_in_scope(:global_alias,:server)         { |alias_name|    current_scope_object.global_alias = alias_name         }
    define_method_in_scope(:env, :server)                 { |env|           current_scope_object.env(env)                          }
    define_method_in_scope(:identity_file, :server)       { |identity_file| current_scope_object.identity_file = identity_file     }
    define_method_in_scope(:default_command, :server)     { |command|       current_scope_object.default_command = command         }
    define_method_in_scope(:execute, :command)            { |command|       current_scope_object.command = command                 }
    define_method_in_scope(:desc, :command)               { |description|   current_scope_object.description = description         }

    define_method_in_scope(:default_server_config, :config, :project, :environment, :group) do |blk|
      current_scope_object.default_server_config = blk
    end

    define_method_in_scope(:shared_server_config, :config) do |name, blk|
      @shared_server_configs.store(name.to_sym, blk)
    end

    define_method_in_scope(:include_shared_server_config, :server) do |*args|
      extract_config_names_and_arguments(args).each do |config_name, arguments|
        instance_exec(*arguments, &shared_server_configs[config_name])
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

    def in_scope(scope, new_scope_object)
      parent_scope_object, @current_scope_object = @current_scope_object, new_scope_object
      @scope.push(scope)
      parent_scope_object.send("append_#{scope}", current_scope_object)
      current_scope_object.parent = parent_scope_object
      yield
      @scope.pop
      @current_scope_object = parent_scope_object
    end

    def ensure_nesting_allowed!(scope, parent_scopes)
      if Array(parent_scopes).none? { |s| current_scope?(s) }
        raise ScopeError, "#{scope} can't be defined in #{current_scope} scope"
      end
    end

    def extract_config_names_and_arguments(args)
      hashes, names = args.partition { |arg| arg.is_a? Hash }
      configs_from_hashes = hashes.inject({}, &:merge)
      configs_from_names = Hash[names.map { |config_name| [config_name.to_sym, []] }]
      configs_from_hashes.merge(configs_from_names)
    end

  end
end

