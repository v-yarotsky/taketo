module Taketo
  module Commands

    class SSHCommand
      include SSHOptions

      def initialize(server, options = {})
        @server = server
      end

      def render(rendered_command)
        %Q[#{program} #{port} #{identity_file} #{username}#{host} "#{rendered_command}"].squeeze(" ")
      end

      def program
        "ssh -t"
      end
    end

  end
end

