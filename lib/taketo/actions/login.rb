require 'taketo/commands/ssh_command'
require 'taketo/actions/base_action'
require 'taketo/actions/server_action'

module Taketo
  module Actions

    class Login < BaseAction
      include ServerAction

      def run
        server = resolver.resolve
        server_command = remote_command(server)
        command_to_execute = Commands::SSHCommand.new(server).render(server_command.render(server, options))
        execute(command_to_execute)
      end

      private

      def remote_command(server)
        command = options[:command]
        if String(command).empty?
          server.default_command
        else
          server.find_command(command.to_sym) || Constructs::Command.explicit_command(command)
        end
      end

      def execute(shell_command)
        if options[:dry_run]
          puts shell_command
        else
          system shell_command
        end
      end
    end

  end
end
