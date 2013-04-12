module Taketo

  module Printer
    def initialize
      @indent_level = 0
      @print_result = ""
    end

    def result
      @print_result.chomp
    end

    private

    def indent(level = nil)
      @first_indent ||= level || @indent_level
      level ? @indent_level = level - @first_indent : @indent_level += 1
      yield
    end

    def put(str = nil)
      @print_result += ("  " * @indent_level + str.to_s).rstrip.chomp + "\n"
    end

    def put_optional(str, value)
      put "#{str} #{value}" if value
    end
  end

end

