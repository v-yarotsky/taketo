module Taketo
  module Constructs

    class Environment < BaseConstruct
      accepts_node_types :group, :server

      def initialize(name)
        super(name)
      end

      def project_name
        if parent.is_a?(Project)
          parent.name
        else
          ""
        end
      end

      def rails_env
        name.to_s
      end
    end

  end
end

