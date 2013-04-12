require 'forwardable'
require 'shellwords'

module Taketo
  module Commands

    class SSHCommand
      extend Forwardable
      include Shellwords

      def initialize(server, options = {})
        @server = server
      end

      def render(rendered_command)
        %Q[ssh -t #{port} #{identity_file} #{username}#{host} "#{rendered_command}"].squeeze(" ")
      end

      def host
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

