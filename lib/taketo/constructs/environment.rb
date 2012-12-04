require 'taketo/constructs/base_construct'
require 'taketo/constructs/project'
require 'taketo/support'

module Taketo
  module Constructs
    class Environment < BaseConstruct
      has_nodes :servers, :server

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
    end
  end
end

