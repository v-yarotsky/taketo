require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Project < BaseConstruct
      has_nodes :environments, :environment
    end
  end
end

