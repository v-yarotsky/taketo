module Taketo
  module Constructs

    class Project < BaseConstruct
      accepts_node_types :group, :environment, :server
    end

  end
end

