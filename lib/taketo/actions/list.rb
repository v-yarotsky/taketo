module Taketo
  module Actions

    class List < BaseAction
      def run
        node = NodeResolvers::GroupResolver.new(config, destination_path).resolve
        traverser = Support::ConfigTraverser.new(node)
        lister = ConfigVisitors::GroupListVisitor.new
        traverser.visit_depth_first(lister)
        puts lister.result
      end
    end

  end
end

