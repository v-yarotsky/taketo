module Taketo

  module Constructs
    def downcased_construct_class_name(klass)
      klass.name.gsub("Taketo::Constructs::", "").gsub(/[A-Z][^A-Z]*/) { |s| s.gsub("::", "").downcase + "_" }.chop
    end
    module_function :downcased_construct_class_name

    autoload :BaseConstruct, 'taketo/constructs/base_construct'
    autoload :Config,        'taketo/constructs/config'
    autoload :Project,       'taketo/constructs/project'
    autoload :Environment,   'taketo/constructs/environment'
    autoload :Server,        'taketo/constructs/server'
    autoload :Group,         'taketo/constructs/group'
  end

end

