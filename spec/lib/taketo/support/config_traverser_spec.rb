require 'spec_helper'
require 'support/helpers/construct_spec_helper'

# config           1--
#                 / \ \
# project        1   2 server_3
#               / \
# environment  1   2
#                 /|\
# server         1 2 3

module Taketo::Support

  describe ConfigTraverser do
    include ConstructsFixtures

    let(:server_1) { server(:Server1) }
    let(:server_2) { server(:Server2) }
    let(:server_3) { server(:Server3) }

    let(:environment_1) { environment(:Environment1) }
    let(:environment_2) { environment(:Environment2, :servers => [server_1, server_2]) }

    let(:project_1) { project(:Project1, :environments => [environment_1, environment_2]) }
    let(:project_2) { project(:Project2) }

    let(:config) { create_config(:projects => [project_1, project_2], :servers => server_3) }

    let(:traverser) { described_class.new(config) }

    class PrintingVisitor
      attr_reader :result

      def initialize
        @result = []
      end

      def visit(node)
        @result << node.name
      end
    end

    describe "#visit_depth_first" do
      it "traverses in depth with visitor" do
        visitor = PrintingVisitor.new
        traverser.visit_depth_first(visitor)
        visitor.result.should == [config, server_3, project_1, environment_1, environment_2, server_1, server_2, project_2].map(&:name)
      end
    end
  end

end

