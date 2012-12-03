require 'taketo/constructs'

module Taketo
  def self.downcased_construct_class_name(klass)
    klass.name.gsub("Taketo::Constructs::", "").gsub(/[A-Z][^A-Z]*/) { |s| s.gsub("::", "").downcase + "_" }.chop
  end

  class ConfigVisitor
    include Taketo::Constructs

    def self.visit(*klasses, &block)
      klasses.each do |klass|
        define_method(:"visit_#{Taketo.downcased_construct_class_name(klass)}", block)
      end
    end

    def visit(obj)
      obj.class.ancestors.each do |ancestor|
        next unless ancestor.name # skip anonymous classes
        method_name = :"visit_#{Taketo.downcased_construct_class_name(ancestor)}"
        next unless respond_to?(method_name)
        return send(method_name, obj)
      end
    end
  end

  def SimpleCollector(*types)
    Class.new(ConfigVisitor) do
      attr_reader :result

      def initialize
        @result = []
      end

      types.each do |t|
        visit t do |n|
          @result << n
        end
      end
    end
  end
end

