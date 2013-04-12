require 'taketo/actions/login'
require 'taketo/actions/view'
require 'taketo/actions/list'
require 'taketo/actions/matches'
require 'taketo/actions/generate_ssh_config'
require 'taketo/actions/edit_config'

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
  end

end

