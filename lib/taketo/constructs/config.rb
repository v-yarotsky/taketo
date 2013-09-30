module Taketo
  module Constructs

    class Config < BaseConstruct
      accepts_node_types :group, :project, :server

      attr_accessor :default_destination

      def initialize(*args)
        super(nil)
      end
    end

  end
end

