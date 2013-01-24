require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Project < BaseConstruct
      has_nodes :environments, :environment
      has_nodes :servers, :server
      has_nodes :groups, :group

      def has_servers?
        has_nodes?(:servers) || environments.any?(&:has_servers?) || groups.any?(&:has_servers?)
      end
    end
  end
end

