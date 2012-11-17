require 'taketo/config_visitor'

module Taketo
  class SSHConfigGeneratorVisitor < ConfigVisitor
    def initialize
      @result = ""
    end

    visit Server do |server|
      put "Host #{server.global_alias || server.host}"
      put "Hostname #{server.host}"
      put_optional "Port", server.port
      put_optional "User", server.username
      put_optional "IdentityFile", server.identity_file
      put
    end

    visit Object do |_|
      # catch all
    end

    def result
      @result.chomp
    end

    private

    def put(str = "")
      @result += str + "\n"
    end

    def put_optional(str, value)
      put "#{str} #{value}" if value
    end
  end
end
