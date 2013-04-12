require 'taketo/constructs/base_construct'
require 'shellwords'

module Taketo
  module Constructs

    class Command < BaseConstruct
      include Shellwords

      attr_accessor :command, :description

      def self.default
        new(:default).tap { |cmd| cmd.command = "bash" }
      end

      def self.explicit_command(command_string)
        new(:explicit_command).tap { |cmd| cmd.command = command_string.to_s }
      end

      def render(server, options = {})
        %Q[#{location(server, options)} #{environment_variables(server)} #{command}].strip.squeeze(" ")
      end

      def to_s
        command.to_s
      end

      private

      def location(server, options = {})
        directory = options.fetch(:directory) { server.default_location }
        %Q[cd #{shellescape directory};] if directory
      end

      def environment_variables(server)
        server.environment_variables.map { |k, v| %Q[#{k}=#{shellescape v}] }.join(" ")
      end
    end

  end
end


