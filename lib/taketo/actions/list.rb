require 'taketo/group_list_visitor'
require 'taketo/actions/base_action'

module Taketo
  module Actions

    class List < BaseAction
      def run
        node = resolver.get_node
        traverser = ConfigTraverser.new(node)
        lister = GroupListVisitor.new
        traverser.visit_depth_first(lister)
        puts lister.result
      end
    end

  end
end

