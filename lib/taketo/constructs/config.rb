module Taketo
  module Constructs
    class Config
      attr_reader :projects

      def initialize
        @projects = {}
      end

      def append_project(project)
        @projects[project.name] = project
      end
    end
  end
end

