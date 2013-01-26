require 'taketo/node_resolver'

module Taketo

  class GroupResolver < NodeResolver
    def nodes
      super.select { |n| [Taketo::Constructs::Config, Taketo::Constructs::Project, Taketo::Constructs::Environment, Taketo::Constructs::Group].include?(n.class) }
    end
  end

end

