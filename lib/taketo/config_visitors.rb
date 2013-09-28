module Taketo

  module ConfigVisitors
    def SimpleCollector(*types)
      Class.new(BaseVisitor) do
        attr_reader :result

        def initialize
          @result = []
        end

        types.each do |t|
          visit t do |n|
            @result << n
          end
        end
      end
    end
    module_function :SimpleCollector

    autoload :BaseVisitor,               'taketo/config_visitors/base_visitor'
    autoload :PrinterVisitor,            'taketo/config_visitors/printer_visitor'
    autoload :SSHConfigGeneratorVisitor, 'taketo/config_visitors/ssh_config_generator_visitor'
    autoload :GroupListVisitor,          'taketo/config_visitors/group_list_visitor'
    autoload :ValidatorVisitor,          'taketo/config_visitors/validator_visitor'
  end


end
