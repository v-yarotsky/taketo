module Taketo
  module Support

    module Inflections
      extend self

      def to_singular(thing)
        str = name(thing)
        str.chop! if plural?(str)
        str.to_sym
      end

      def to_plural(thing)
        str = name(thing)
        str << "s" unless plural?(str)
        str.to_sym
      end

      def to_class(thing, nesting = Module.nesting.first || Object)
        nesting.const_get(class_name_from_string(to_singular(thing)))
      end

      private

      def name(thing)
        thing.is_a?(Class) ? name_from_class(thing) : thing.to_s
      end

      def name_from_class(klass)
        klass.name.gsub(/[A-Za-z0-9]+::/, "").gsub(/[A-Z][^A-Z]*/) { |s| s.gsub("::", "").downcase + "_" }.chop
      end

      def class_name_from_string(singular)
        singular.to_s.gsub(/(^|_)\w/) { |s| s.gsub(/_/, "").capitalize }
      end

      def plural?(str)
        str =~ /s$/
      end
    end

  end
end

