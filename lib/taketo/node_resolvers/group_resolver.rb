module Taketo
  module NodeResolvers

    class GroupResolver < BaseResolver
      def nodes
        super.select { |n| [Taketo::Constructs::Config, Taketo::Constructs::Project, Taketo::Constructs::Environment, Taketo::Constructs::Group].include?(n.class) }
      end
    end

  end
end

