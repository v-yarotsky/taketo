require 'taketo/node_resolver'

module Taketo

  class GroupResolver < NodeResolver
    def nodes
      super.reject { |n| Taketo::Constructs::Server === n }
    end
  end

end

