require 'shellwords'

module Taketo
  module Constructs
    class Command
      include Shellwords

      attr_reader :name
      attr_accessor :command
      
      def initialize(name)
        @name = name
      end

      def render(server)
        %Q[#{location(server)} #{environment_variables(server)} #{command}].squeeze(" ")
      end

      private

      def location(server)
        %Q[cd #{shellescape server.default_location};] if server.default_location
      end

      def environment_variables(server)
        server.environment_variables.map { |k, v| %Q[#{k}=#{shellescape v}] }.join(" ")
      end
    end
  end
end


