require 'set'

module Taketo

  # TODO make it immutable maybe?
  class ServerConfig
    FIELDS = [:ssh_command, :host, :port, :username, :default_location, :default_command, :identity_file, :global_alias].freeze
    attr_accessor *FIELDS
    attr_reader :environment_variables, :commands

    def initialize(config_hash = {})
      @environment_variables = {}
      @commands = Set.new
      merge!(config_hash)
      yield self if block_given?
    end

    def ssh_command=(value)
      @ssh_command = value.to_sym
    end

    def global_alias=(value)
      @global_alias = value.to_s
    end

    def merge(server_config)
      dup.merge!(server_config)
    end

    def merge!(server_config)
      config_hash = server_config.to_h
      FIELDS.each { |f| send("#{f}=", config_hash[f]) if config_hash.key?(f) }
      add_environment_variables(config_hash[:environment_variables])
      Array(config_hash[:commands]).each { |c| add_command(c) }
      self
    end
    protected :merge!

    def dup
      Marshal.load(Marshal.dump(self))
    end

    def to_h
      values = FIELDS.map { |f| send(f) }
      Hash[FIELDS.zip(values).reject { |k, v| v.nil? }].merge(:environment_variables => environment_variables, :commands => commands)
    end

    def add_command(cmd)
      @commands << cmd
    end

    def add_environment_variables(env_variables)
      @environment_variables.merge!(Hash[Array(env_variables)])
    end

    def include_shared_server_config(server_config)
      merge!(server_config)
    end

    # overriding command?

  end

end
