require 'forwardable'
require 'shellwords'

module Taketo
  module Commands
    class SSHCommand
      extend Forwardable
      include Shellwords

      def_delegators :@server, :host, :port, :username, :default_location

      def initialize(server, options = {})
        @server = server
        @environment = @server.environment
      end

      def render(command = "bash", env_variables = [])
        env_variables = (Array(env_variables) + Array(default_env_variables)).join(" ")
        %Q[ssh -t #{port} #{username}#{host} "#{[location, env_variables, command].compact.join(" ")}"].squeeze(" ")
      end

      def host
        unless @server.host
          raise ArgumentError, "host for server #{@server.name} in #{@environment.name} is not defined!"
        end
        shellescape @server.host
      end

      def port
        %Q[-p #{@server.port}] if @server.port
      end

      def username
        %Q[#{shellescape @server.username}@] if @server.username
      end

      def location
        %Q[cd #{shellescape @server.default_location};] if @server.default_location
      end

      def default_env_variables
        [%Q[RAILS_ENV=#{shellescape @environment.name.to_s}], *server_env_variables]
      end

      private

      def server_env_variables
        @server.environment_variables.map { |k, v| %Q[#{k}=#{shellescape v}] }
      end
    end
  end
end

