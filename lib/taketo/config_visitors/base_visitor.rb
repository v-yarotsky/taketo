module Taketo
  module ConfigVisitors

    class BaseVisitor
      include Taketo::Constructs
      extend  Taketo::Constructs

      def self.visit(*klasses, &block)
        klasses.each do |klass|
          define_method(:"visit_#{downcased_construct_class_name(klass)}", block)
        end
      end

      def visit(obj)
        obj.class.ancestors.each do |ancestor|
          next unless ancestor.name # skip anonymous classes
          method_name = :"visit_#{downcased_construct_class_name(ancestor)}"
          next unless respond_to?(method_name)
          return send(method_name, obj)
        end
      end
    end

  end
end
