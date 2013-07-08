require 'taketo/support'

module Taketo
  module Constructs

    class Config < BaseConstruct
      has_nodes :groups, :group
      has_nodes :projects, :project
      has_nodes :servers, :server

      attr_accessor :default_destination

      def initialize(*args)
        super(nil)
      end

      def has_servers?
        has_deeply_nested_nodes?(:servers)
      end
    end

  end
end

