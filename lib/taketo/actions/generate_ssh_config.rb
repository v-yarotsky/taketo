module Taketo
  module Actions

    class GenerateSshConfig < BaseAction
      def run
        traverser = Support::ConfigTraverser.new(config)
        ssh_config_generator = ConfigVisitors::SSHConfigGeneratorVisitor.new
        traverser.visit_depth_first(ssh_config_generator)
        puts ssh_config_generator.result
      end
    end

  end
end

