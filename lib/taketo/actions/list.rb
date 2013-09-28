require 'taketo/config_visitors'
require 'taketo/actions/base_action'
require 'taketo/node_resolvers'

module Taketo
  module Actions

    class List < BaseAction
      def run
        node = NodeResolvers::GroupResolver.new(config, destination_path).resolve
        traverser = ConfigTraverser.new(node)
        lister = ConfigVisitors::GroupListVisitor.new
        traverser.visit_depth_first(lister)
        puts lister.result
      end
    end

  end
end

