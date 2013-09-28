module Taketo
  module ConfigVisitors

    class ValidatorVisitor < BaseVisitor
      def initialize
        @global_server_aliases = {}
      end

      visit Config do |c|
        raise ConfigError, "There are no servers. Add some to your config (~/.taketo.rc.rb by default)" unless c.has_servers?
      end

      visit Project do |p|
        raise ConfigError, "Project #{p.path}: no servers" unless p.has_servers?
      end

      visit Environment do |e|
        raise ConfigError, "Environment #{e.path}: no servers" unless e.has_servers?
      end

      visit Group do |g|
        raise ConfigError, "Group #{g.path}: no servers" unless g.has_servers?
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
      end

      visit Command do |c|
        raise ConfigError, "Don't know what to execute on command #{c.name}" if String(c.command).empty?
      end
    end

  end
end

