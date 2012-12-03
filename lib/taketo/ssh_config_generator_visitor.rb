require 'taketo/config_visitor'
require 'taketo/printer'

module Taketo
  class SSHConfigGeneratorVisitor < ConfigVisitor
    include Printer

    visit Server do |server|
      put "Host #{server.global_alias || server.host}"
      put "Hostname #{server.host}"
      put_optional "Port", server.port
      put_optional "User", server.username
      put_optional "IdentityFile", server.identity_file
      put
    end
  end
end
