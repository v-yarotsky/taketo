require 'taketo/config_traverser'
require 'taketo/ssh_config_generator_visitor'
require 'taketo/actions/base_action'
require 'taketo/actions/server_action'

module Taketo
  module Actions

    class GenerateSshConfig < BaseAction
      include ServerAction

      def run
        traverser = ConfigTraverser.new(config)
        ssh_config_generator = SSHConfigGeneratorVisitor.new
        traverser.visit_depth_first(ssh_config_generator)
        puts ssh_config_generator.result
      end
    end

  end
end

