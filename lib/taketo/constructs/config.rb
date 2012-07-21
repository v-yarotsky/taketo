require 'taketo/constructs/base_construct'
require 'taketo/support'

module Taketo
  module Constructs
    class Config < BaseConstruct
      attr_reader :projects
      attr_accessor :default_destination

      def initialize
        @projects = Taketo::Support::NamedNodesCollection.new
      end

      def append_project(project)
        @projects << project
      end

      def find_project(name)
        @projects.find_by_name(name)
      end
    end
  end
end

