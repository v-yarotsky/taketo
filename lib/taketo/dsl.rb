require 'taketo/support'

module Taketo
  class DSL
    class ScopeError < StandardError; end
    
    class << self
      def define_scope(scope, parent_scope)
        define_method scope do |name, &block|
          unless current_scope?(parent_scope)
            raise ScopeError,
              "#{scope} can't be defined in #{current_scope} scope"
          end
          scope_object = @factory.send("create_#{scope}", name)
          in_scope(scope, scope_object) do
            block.call
          end
        end
      end

      def define_attribute(name, parent_scope, &block)
        define_method name do |attribute|
          unless server_scope?
            raise ScopeError,
              "#{name} can't be defined in #{current_scope} scope"
          end
          instance_exec(attribute, &block)
        end
      end
    end

    attr_reader :current_scope_object, :config

    def initialize(factory)
      @factory = factory
      @scope = [:config]
      @config = @current_scope_object = factory.create_config
    end

    def configure(&block)
      instance_eval(&block)
      @config
    end

    define_scope :project, :config
    define_scope :environment, :project
    define_scope :server, :environment

    define_attribute :host, :server do |hostname|
      current_scope_object.host = hostname
    end

    define_attribute :port, :server do |port_number|
      current_scope_object.port = port_number
    end

    define_attribute :user, :server do |username|
      current_scope_object.username = username
    end

    define_attribute :location, :server do |path|
      current_scope_object.default_location = path
    end

    private

    def current_scope
      @scope.last
    end

    def current_scope?(scope)
      current_scope == scope
    end

    [:config, :project, :environment, :server].each do |scope|
      define_method("#{scope}_scope?") { current_scope == scope }
    end

    def in_scope(scope, new_scope_object)
      parent_scope_object, @current_scope_object = @current_scope_object, new_scope_object
      @scope << scope
      yield
      parent_scope_object.send("append_#{scope}", current_scope_object) 
      @scope.pop
      @current_scope_object = parent_scope_object
    end

  end
end
