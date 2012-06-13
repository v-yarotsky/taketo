module Taketo
  class ConfigError < StandardError; end

  class TaketoArgvParser
    def initialize(config, argv)
      @config = config
      @argv   = argv
    end

    def parse
      if all_specified?
        project_name, environment_name, server_name = @argv.shift(3).map(&:to_sym)

        begin
          return @config.projects[project_name].environments[environment_name].servers[server_name]
        rescue KeyError
          raise ArgumentError,
            "Server #{server_name} in environment #{environment_name} for project #{project_name} does not exist"
        end
      end

      if @config.projects.one?
        project = @config.projects.first
        if project.environments.one?
          environment = project.environments.first
          if environment.servers.one?
            return environment.servers.first
          elsif environment.servers.length > 1
            if server_name = @argv.shift
              return environment.servers[server_name.to_sym]
            else
              raise ArgumentError, "There are multiple servers for project #{project.name} " \
                "in environment #{environment.name}: #{environment.servers.map(&:name).join(", ")}"
            end
          end
        end
      end
    end

    private

    def all_specified?
      @argv.size >= 3
    end

  end
end

