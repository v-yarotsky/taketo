module Taketo
  module Actions

    # TODO rename to RunCommand or something
    class Login < BaseAction
      def run
        server = NodeResolvers::ServerResolver.new(config, destination_path).resolve
        server_command = remote_command(server)
        command_to_execute = Commands[server.ssh_command].new(server).render(server_command)
        execute(command_to_execute)
      end

      private

      def remote_command(server)
        command_name = String(options[:command]).empty? ? server.default_command : options[:command]
        command = server.fetch_command(command_name)
        command_renderer = ::Taketo::Support::CommandRenderer.new(server, options)
        command_renderer.render(command)
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

