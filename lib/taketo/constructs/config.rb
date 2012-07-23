require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Config < BaseConstruct
      has_nodes :projects, :project

      attr_accessor :default_destination

      def initialize(*args)
        super(nil)
      end
    end
  end
end

