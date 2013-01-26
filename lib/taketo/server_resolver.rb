require 'taketo/node_resolver'
require 'taketo/constructs/server'

module Taketo

  class ServerResolver < NodeResolver
    def nodes
      super.select { |n| Taketo::Constructs::Server === n }
    end
    alias :servers :nodes

    def resolve
      resolve_by_global_alias || resolve_by_path
    end

    def resolve_by_global_alias
      unless @path.to_s.empty?
        servers.select(&:global_alias).detect { |s| s.global_alias == @path.to_s }
      end
    end

    def resolve_by_path
      matching_servers = servers.select { |s| s.path =~ /^#@path/ }
      disambiguate(matching_servers)
    end
  end

end

