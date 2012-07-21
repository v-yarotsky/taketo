require 'taketo/support'

module Taketo
  module Constructs
    class BaseConstruct
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def find(scope, name)
        send("find_#{scope}", name) or
          if block_given?
            yield
          else
            raise KeyError, "#{scope.to_s.capitalize} #{name} not found for #{self.class.name} #{name}"
          end
      end
    end
  end
end


