require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Group < BaseConstruct
      has_nodes :servers, :server

      def rails_env
        parent.rails_env if parent.respond_to?(:rails_env)
      end
    end
  end
end


