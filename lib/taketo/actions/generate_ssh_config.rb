require 'taketo/config_traverser'
require 'taketo/config_visitors'
require 'taketo/actions/base_action'

module Taketo
  module Actions

    class GenerateSshConfig < BaseAction
      def run
        traverser = ConfigTraverser.new(config)
        ssh_config_generator = ConfigVisitors::SSHConfigGeneratorVisitor.new
        traverser.visit_depth_first(ssh_config_generator)
        puts ssh_config_generator.result
      end
    end

  end
end

