require 'taketo/group_list_visitor'
require 'taketo/actions/base_action'
require 'taketo/group_resolver'

module Taketo
  module Actions

    class List < BaseAction
      def run
        node = GroupResolver.new(config, destination_path).resolve
        traverser = ConfigTraverser.new(node)
        lister = GroupListVisitor.new
        traverser.visit_depth_first(lister)
        puts lister.result
      end
    end

  end
end

