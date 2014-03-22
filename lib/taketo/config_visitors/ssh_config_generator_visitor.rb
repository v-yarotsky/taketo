module Taketo
  module ConfigVisitors

    class SSHConfigGeneratorVisitor < BaseVisitor
      include Support::Printer

      visit Server do |server|
        put_server(server, server.global_alias) unless server.global_alias.to_s.empty?
        put_server(server, server.host)
      end

      def put_server(server, host)
        put "Host #{host}"
        put "Hostname #{server.host}"
        put_optional "Port", server.port
        put_optional "User", server.username
        put_optional "IdentityFile", server.identity_file
        put
      end
    end

  end
end
