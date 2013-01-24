require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Group < BaseConstruct
      has_nodes :servers, :server
    end
  end
end


