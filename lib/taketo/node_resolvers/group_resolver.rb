module Taketo
  module NodeResolvers

    class GroupResolver < BaseResolver
      def nodes
        super.select { |n| [:config, :project, :environment, :group].include?(n.node_type) }
      end
    end

  end
end

