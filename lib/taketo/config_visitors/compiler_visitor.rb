module Taketo
  module ConfigVisitors

    class CompilerVisitor < BaseVisitor
      attr_reader :path_stack, :server_configs_stack

      def initialize
        @path_stack = []
        @server_configs_stack = []
      end

      visit Config, Project, Environment, Group do |n|
        @server_configs_stack.push(n.default_server_config)
        n.path = make_node_path(n)
        @path_stack.push(n.name) if n.name
      end

      after_visit Config, Project, Environment, Group do |c|
        @server_configs_stack.pop
        @path_stack.pop
      end

      visit Server do |s|
        s.config = @server_configs_stack.inject(::Taketo::Support::ServerConfig.new, &:merge).merge(s.config)
        s.path = make_node_path(s)
      end

      def make_node_path(node)
        [*@path_stack, node.name].join(":")
      end
    end

  end
end

