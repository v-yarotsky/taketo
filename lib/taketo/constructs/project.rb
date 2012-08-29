require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Project < BaseConstruct
      has_nodes :environments, :environment

      def append_environment(environment)
        environment.project = self
        super
      end
    end
  end
end

