require 'taketo/support'
require 'taketo/associated_nodes'

module Taketo
  module Constructs
    class BaseConstruct

      include AssociatedNodes
      attr_reader :name

      def initialize(name)
        super
        @name = name
      end

      def node_type
        demodulized = self.class.name.gsub(/.*::/, '')
        demodulized.gsub(/([a-z])([A-Z])/, '\\1_\\2').downcase.to_sym
      end

      def qualified_name
        "#{node_type} #{self.name}"
      end

    end
  end
end


