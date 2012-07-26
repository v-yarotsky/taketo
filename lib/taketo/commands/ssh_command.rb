require 'forwardable'
require 'shellwords'

module Taketo
  module Commands
    class SSHCommand
      extend Forwardable
      include Shellwords

      def initialize(server, options = {})
        @server = server
        @environment = @server.environment
      end

      def render(rendered_command)
        %Q[ssh -t #{port} #{identity_file} #{username}#{host} "#{rendered_command}"].squeeze(" ")
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

      def identity_file
        %Q[-i #{shellescape @server.identity_file}] if @server.identity_file
      end
    end
  end
end

