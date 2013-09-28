module Taketo
  module Actions

    class View < BaseAction
      def run
        config.default_destination = nil
        node = NodeResolvers::BaseResolver.new(config, destination_path).resolve
        traverser = Support::ConfigTraverser.new(node)
        config_printer = ConfigVisitors::PrinterVisitor.new
        traverser.visit_depth_first(config_printer)
        puts config_printer.result
      end
    end

  end
end

