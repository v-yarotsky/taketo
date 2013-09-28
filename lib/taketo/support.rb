module Taketo

  module Support
    autoload :Inflections,          'taketo/support/inflections'
    autoload :NamedNodesCollection, 'taketo/support/named_nodes_collection'
    autoload :Printer,              'taketo/support/printer'
    autoload :AssociatedNodes,      'taketo/support/associated_nodes'
    autoload :ConfigTraverser,      'taketo/support/config_traverser'
    autoload :ConfigValidator,      'taketo/support/config_validator'
    autoload :DestinationMatcher,   'taketo/support/destination_matcher'
  end

end

