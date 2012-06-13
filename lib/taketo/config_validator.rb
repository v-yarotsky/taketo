module Taketo
  class ConfigError < StandardError; end

  class ConfigValidator
    def initialize(config)
      @config = config
    end

    def validate!
      ensure_projects_exist
      ensure_environments_exist
      ensure_servers_exist
    end

    private

    def ensure_projects_exist
      if @config.projects.empty?
        raise ConfigError,
          "There are no projects. Add some to your config (~/.taketo.rc.rb by default)"
      end
    end

    def ensure_environments_exist
      projects_without_environments = @config.projects.select { |project| project.environments.empty? }
      if projects_without_environments.any?
        raise ConfigError,
          "There is no environments for the following projects: #{projects_without_environments.map(&:name).join(", ")}"
      end
    end

    def ensure_servers_exist
      @config.projects.each do |project|
        environments_without_servers = project.environments.select { |environment| environment.servers.empty? }
        if environments_without_servers.any?
          raise ConfigError,
            "There is no servers for the following environments in project #{project.name}: #{environments_without_servers.map(&:name).join(", ")}"
        end
      end
    end
  end
end

