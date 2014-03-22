module Taketo
  module ConfigVisitors

    class BaseVisitor
      include Taketo::Constructs
      extend  Taketo::Constructs # for downcased_construct_class_name

      def self.visit(*klasses, &block)
        klasses.each do |klass|
          define_method(method_name_for_klass(klass, :visit), block)
        end
      end

      def self.after_visit(*klasses, &block)
        klasses.each do |klass|
          define_method(method_name_for_klass(klass, :after_visit), block)
        end
      end

      # private
      def self.method_name_for_klass(klass, prefix)
        [prefix.to_s, downcased_construct_class_name(klass)].join("_")
      end

      def visit(obj)
        run_appropriate_callback(obj, :visit)
      end

      def after_visit(obj)
        run_appropriate_callback(obj, :after_visit)
      end

      private

      def run_appropriate_callback(obj, method_name_prefix)
        obj.class.ancestors.each do |ancestor|
          next unless ancestor.name # ignore anonymous classes/modules
          method_name = self.class.method_name_for_klass(ancestor, method_name_prefix)
          next unless respond_to?(method_name)
          return send(method_name, obj)
        end
      end
    end

  end
end
