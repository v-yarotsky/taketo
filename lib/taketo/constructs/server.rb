require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Server < BaseConstruct
      class CommandNotFoundError < StandardError; end

      attr_reader :environment_variables, :commands
      attr_accessor :host, :port, :username, :default_location, :environment
      
      def initialize(name)
        super
        @environment_variables = {}
        @commands = Taketo::Support::NamedNodesCollection.new
      end

      def env(env_variables)
        @environment_variables.merge!(env_variables)
      end

      def append_command(command)
        @commands << command
      end

      def find_command(name)
        @commands.find_by_name(name)
      end

      def environment=(environment)
        env(:RAILS_ENV => environment.name.to_s)
        @environment = environment
      end
    end
  end
end

