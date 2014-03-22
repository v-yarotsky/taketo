module Taketo
  module Support

    class Command
      attr_accessor :name, :command, :description

      def self.explicit_command(explicit_command)
        new(:explicit_command) { |c| c.command = explicit_command.to_s; c.name = explicit_command.to_s }
      end

      def initialize(name)
        @name = name.to_s
        yield self if block_given?
      end

      def ==(other)
        return self.class.equal?(other.class) &&
               name == other.name &&
               command == other.command &&
               description == other.description
        false
      end

      def hash
        name.hash ^ command.hash ^ description.hash
      end

      def to_s
        command.to_s.dup
      end
    end

  end
end
