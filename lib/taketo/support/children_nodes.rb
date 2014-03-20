module Taketo
  module Support

    module ChildrenNodes
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
      end

      module ClassMethods
        def accepts_node_types(*node_types)
          allowed_node_types = node_types.freeze
          define_method(:allowed_node_types) { allowed_node_types }
        end
      end

      module InstanceMethods
        def nodes
          @nodes ||= []
        end

        def allowed_node_types
          []
        end

        def add_node(node)
          unless allowed_node_types.include?(node.node_type)
            raise ArgumentError, "#{node.node_type} can not be added in #{node_type} scope"
          end
          unless nodes.include?(node)
            node.parent = self
            nodes << node
          end
        end

        def <<(node)
          add_node(node)
          self
        end

        def find_node_by_type_and_name(node_type, node_name)
          nodes.detect { |n| n.node_type == node_type && n.name == node_name } or (yield if block_given?)
        end

        def has_nodes?(node_type)
          nodes.any? { |n| n.node_type == node_type }
        end

        def node_type
          raise NotImplementedError
        end
      end
    end

  end
end

