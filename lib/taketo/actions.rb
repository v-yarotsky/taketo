module Taketo

  module Actions
    def self.[](name)
      actions_map = {
        :login               => Login,
        :view                => View,
        :list                => List,
        :matches             => Matches,
        :generate_ssh_config => GenerateSshConfig,
        :edit_config         => EditConfig
      }
      actions_map.fetch(name) { Login }
    end

    autoload :BaseAction,        'taketo/actions/base_action'
    autoload :Login,             'taketo/actions/login'
    autoload :View,              'taketo/actions/view'
    autoload :List,              'taketo/actions/list'
    autoload :Matches,           'taketo/actions/matches'
    autoload :GenerateSshConfig, 'taketo/actions/generate_ssh_config'
    autoload :EditConfig,        'taketo/actions/edit_config'
  end

end

