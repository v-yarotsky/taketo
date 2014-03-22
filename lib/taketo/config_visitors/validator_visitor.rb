module Taketo
  module ConfigVisitors

    class ValidatorVisitor < BaseVisitor
      def initialize
        @global_server_aliases = {}
      end

      visit Config do |c|
        raise ConfigError, "There are no servers. Add some to your config (~/.taketo.rc.rb by default)" unless node_has_servers?(c)
      end

      visit Project do |p|
        raise ConfigError, "Project #{p.path}: no servers" unless node_has_servers?(p)
      end

      visit Environment do |e|
        raise ConfigError, "Environment #{e.path}: no servers" unless node_has_servers?(e)
      end

      visit Group do |g|
        raise ConfigError, "Group #{g.path}: no servers" unless node_has_servers?(g)
      end

      visit Server do |s|
        if !String(s.global_alias).empty?
          if @global_server_aliases.key?(s.global_alias)
            raise ConfigError, "Server #{s.path}: global alias '#{s.global_alias}' has already been taken by server #{@global_server_aliases[s.global_alias].path}"
          else
            @global_server_aliases[s.global_alias] = s
          end
        end

        raise ConfigError, "Server #{s.path}: host is not defined" if String(s.host).empty?

        s.commands.each do |c|
          raise ConfigError, "Don't know what to execute on command #{c.name}" if String(c.command).empty?
        end
      end

      def node_has_servers?(node)
        servers_collector = ConfigVisitors::SimpleCollector(Taketo::Constructs::Server).new
        traverser = Taketo::Support::ConfigTraverser.new(node)
        traverser.visit_depth_first(servers_collector)
        servers_collector.result.any?
      end
    end

  end
end

