require 'taketo/config_traverser'
require 'taketo/config_printer_visitor'
require 'taketo/actions/base_action'

module Taketo
  module Actions

    class View < BaseAction
      def run
        node = resolver.get_node
        traverser = ConfigTraverser.new(node)
        config_printer = ConfigPrinterVisitor.new
        traverser.visit_depth_first(config_printer)
        puts config_printer.result
      end
    end

  end
end

