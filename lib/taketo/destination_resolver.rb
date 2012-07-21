module Taketo
  class ConfigError < StandardError; end
  class AmbiguousDestinationError < StandardError; end
  class NonExistentDestinationError < StandardError; end

  class DestinationResolver
    def initialize(config, path)
      @config = config
      @path_str = path
      @path = String(path).split(":").map(&:to_sym)
    end

    def resolve
      case @path.size
      when 3 then resolve_by_three_segments
      when 2 then resolve_by_two_segments
      when 1 then resolve_by_one_segment
      when 0 then resolve_with_no_segments
      end
    end

    private

    def resolve_by_three_segments
      get_server(*@path)
    end

    def resolve_by_two_segments
      project, environment = get_project_and_environment(*@path)
      get_only_server_for_project_and_environment(project, environment)
    end

    def resolve_by_one_segment
      project = get_project(*@path)
      get_only_server_for_project(project)
    end

    def resolve_with_no_segments
      get_only_server
    end

    def get_server(project_name, environment_name, server_name)
      handling_failure("There is no such project, environment or server for destination: #@path_str") do
        project, environment = get_project_and_environment(project_name, environment_name)
        environment.servers[server_name]
      end
    end

    def get_project_and_environment(project_name, environment_name)
      handling_failure("There is no such project - environment pair: #@path_str") do
        project = get_project(project_name)
        environment = project.environments[environment_name]
        [project, environment]
      end
    end

    def get_only_server_for_project_and_environment(project, environment)
      if environment.servers.one?
        return environment.servers.first
      else
        raise_server_ambiguous!(project, environment)
      end
    end

    def get_project(project_name)
      handling_failure("There is no such project: #@path_str") do
        @config.projects[project_name]
      end
    end

    def get_only_server_for_project(project)
      if project.environments.one?
        environment = project.environments.first
        get_only_server_for_project_and_environment(project, environment)
      else
        raise_environment_ambiguous!(project)
      end
    end

    def get_only_server
      if @config.projects.one?
        project = @config.projects.first
        get_only_server_for_project(project)
      else
        raise_project_ambiguous!
      end
    end

    def raise_project_ambiguous!
      raise AmbiguousDestinationError, "There are multiple projects #{@config.projects.map(&:name).join(", ")}"
    end

    def raise_environment_ambiguous!(project)
      raise AmbiguousDestinationError, "There are multiple environments for project #{project.name}: " \
        "#{project.environments.map(&:name).join(", ")}"
    end

    def raise_server_ambiguous!(project, environment)
      raise AmbiguousDestinationError, "There are multiple servers for project #{project.name} " \
        "in environment #{environment.name}: #{environment.servers.map(&:name).join(", ")}"
    end

    def handling_failure(message)
      yield
    rescue KeyError, NonExistentDestinationError
      raise NonExistentDestinationError, message
    end
  end
end

