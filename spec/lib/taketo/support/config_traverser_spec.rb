require 'spec_helper'
require 'support/helpers/construct_spec_helper'

# config           1--
#                 / \ \
# project        1   2 server_3
#               / \
# environment  1   2
#                 /|\
# server         1 2 3

module Taketo
  module Support

    describe ConfigTraverser do
      include ConstructsFixtures

      let(:server_1) { server(:Server1) }
      let(:server_2) { server(:Server2) }
      let(:server_3) { server(:Server3) }

      let(:environment_1) { environment(:Environment1) }
      let(:environment_2) { environment(:Environment2, [server_1, server_2]) }

      let(:project_1) { project(:Project1, [environment_1, environment_2]) }
      let(:project_2) { project(:Project2) }

      let(:config) { create_config([project_1, project_2, server_3]) }

      let(:traverser) { described_class.new(config) }

      class PrintingVisitor
        attr_reader :result, :after_visit_result

        def initialize
          @result = []
          @after_visit_result = []
        end

        def visit(node)
          @result << node.name
        end

        def after_visit(node)
          @after_visit_result << node.name
        end
      end

      describe "#visit_depth_first" do
        let(:visitor) { PrintingVisitor.new }

        it "traverses in depth with visitor" do
          traverser.visit_depth_first(visitor)
          expect(visitor.result).to eq([config, project_1, environment_1, environment_2, server_1, server_2, project_2, server_3].map(&:name))
        end

        it "triggers after_visit as needed" do
          traverser.visit_depth_first(visitor)
          expect(visitor.after_visit_result).to eq([environment_1, server_1, server_2, environment_2, project_1, project_2, server_3, config].map(&:name))
        end
      end
    end

  end
end

