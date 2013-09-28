module Taketo
  module ConfigVisitors

    class GroupListVisitor < SimpleCollector(Constructs::Server)
      def result
        @result.map(&:path).join("\n")
      end
    end

  end
end

