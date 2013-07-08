module Taketo
  module Commands

    class MoshCommand
      include SSHOptions

      def initialize(server, options = {})
        @server = server
      end

      def render(rendered_command)
        %Q[#{program} #{ssh_program} -- #{username}#{host} #{remote_shell_program} "#{rendered_command}"].squeeze(" ")
      end

      def program
        "MOSH_TITLE_NOPREFIX=1 mosh --no-init"
      end

      def ssh_program
        %Q[--ssh="ssh #{port} #{identity_file}"].squeeze(" ") if @server.port || @server.identity_file
      end

      def remote_shell_program
        "/bin/sh -c"
      end
    end

  end
end

