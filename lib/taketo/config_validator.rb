require 'taketo/config_traverser'

module Taketo
  class ConfigError < StandardError; end

  class ConfigValidator
    def initialize(traverser)
      @traverser = traverser
    end

    def validate!
      ensure_projects_exist
      ensure_environments_exist
      ensure_servers_exist
      ensure_global_server_aliases_unique
    end

    def ensure_projects_exist
      unless @traverser.get_all_of_level(:config).any? { |c| c.has_projects? }
        raise ConfigError,
          "There are no projects. Add some to your config (~/.taketo.rc.rb by default)"
      end
    end

    def ensure_environments_exist
      projects_without_environments = @traverser.get_all_of_level(:project).reject { |p| p.has_environments? }
      unless projects_without_environments.empty?
        raise ConfigError,
          "There is no environments for the following projects: #{projects_without_environments.map(&:name).join(", ")}"
      end
    end

    def ensure_servers_exist
      environments_without_servers = @traverser.get_all_of_level(:environment).reject { |p| p.has_servers? }
      unless environments_without_servers.empty?
        raise ConfigError,
          "There is no servers for the following environments in project #{environments_without_servers.first.project_name}: #{environments_without_servers.map(&:name).join(", ")}"
      end
    end

    def ensure_global_server_aliases_unique
      aliases = @traverser.get_all_of_level(:server).map(&:global_alias)
      non_uniq_aliases = aliases.reject(&:nil?).group_by(&:to_sym).reject { |k, v| v.size == 1 }
      unless non_uniq_aliases.empty?
        raise ConfigError,
          "There are duplicates among global server aliases: #{non_uniq_aliases.keys.join(", ")}"
      end
    end
  end
end

