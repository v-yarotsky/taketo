require 'shellwords'

module Taketo
  module Support

    class ServerCommandRenderer
      include Shellwords

      def initialize(server, options = {})
        @directory = options.fetch(:directory) { server.default_location }
        @environment_variables = server.environment_variables
      end

      def render(server_command)
        %Q[#{directory} #{environment_variables} #{server_command}].strip.squeeze(" ")
      end

      private

      def directory
        %Q[cd #{shellescape @directory};] if @directory
      end

      def environment_variables
        @environment_variables.map { |k, v| %Q[#{k}=#{shellescape v}] }.join(" ")
      end
    end

  end
end
