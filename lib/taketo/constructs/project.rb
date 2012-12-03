require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Project < BaseConstruct
      has_nodes :environments, :environment
      has_nodes :servers, :server

      def append_environment(environment)
        environment.project = self
        super
      end

      def has_servers?
        has_nodes?(:servers) || environments.any?(&:has_servers?)
      end
    end
  end
end

