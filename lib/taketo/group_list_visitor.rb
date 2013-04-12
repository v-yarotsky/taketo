require 'taketo/config_visitor'
require 'taketo/printer'

module Taketo

  class GroupListVisitor < SimpleCollector(Constructs::Server)
    def result
      @result.map(&:path).join("\n")
    end
  end

end

