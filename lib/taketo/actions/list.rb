require 'taketo/group_list_visitor'
require 'taketo/actions/base_action'
require 'taketo/actions/group_action'

module Taketo
  module Actions

    class List < BaseAction
      include GroupAction

      def run
        node = resolver.resolve
        traverser = ConfigTraverser.new(node)
        lister = GroupListVisitor.new
        traverser.visit_depth_first(lister)
        puts lister.result
      end
    end

  end
end

