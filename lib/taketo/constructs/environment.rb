require 'taketo/constructs/base_construct'
require 'taketo/constructs/project'
require 'taketo/support'

module Taketo
  module Constructs
    class Environment < BaseConstruct
      has_nodes :servers, :server
      has_nodes :groups, :group

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

      def has_servers?
        has_nodes?(:servers) || groups.any?(&:has_servers?)
      end
    end
  end
end

