module Taketo
  module Constructs

    class Group < BaseConstruct
      accepts_node_types :server

      def rails_env
        parent.rails_env if parent.respond_to?(:rails_env)
      end
    end

  end
end


