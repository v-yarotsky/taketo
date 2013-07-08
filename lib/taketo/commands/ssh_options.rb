require 'shellwords'

module Taketo
  module Commands

    module SSHOptions

      include Shellwords
      def initialize(server)
        @server = server
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

