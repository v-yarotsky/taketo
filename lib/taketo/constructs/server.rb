module Taketo
  module Constructs
    class Server
      class CommandNotFoundError < StandardError; end

      attr_reader :name, :environment_variables, :commands
      attr_accessor :host, :port, :username, :default_location, :environment
      
      def initialize(name)
        @name = name
        @environment_variables = {}
        @commands = []
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end

      def append_command(command)
        @commands << command
      end

      def environment=(environment)
        env(:RAILS_ENV => environment.name.to_s)
        @environment = environment
      end

      def command_by_name(command_name)
        @commands.detect { |c| c.name == command_name } or 
          if block_given?
            yield
          else
            raise CommandNotFoundError, "Command #{command_name} not found for server #{name}"
          end
      end

    end
  end
end

