require 'taketo/constructs/base_construct'
require 'shellwords'

module Taketo
  module Constructs
    class Command < BaseConstruct
      include Shellwords

      attr_accessor :command, :description
      
      def render(server)
        %Q[#{location(server)} #{environment_variables(server)} #{command}].strip.squeeze(" ")
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


