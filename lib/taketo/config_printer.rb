module Taketo
  class ConfigPrinter
    def initialize
      @indent_level = 0
      @result = ""
    end

    def result
      @result.chomp
    end

    def render(object)
      method = "render_#{object.node_type}"
      send(method, object)
    end

    def render_command(command)
      put command.name.to_s + (" - " + command.description if command.description).to_s
      result
    end

    def render_server(server)
      section("Server: #{server.name}") do
        put "Host: #{server.host}"
        put "Port: #{server.port}" if server.port
        put "User: #{server.username}" if server.username
        put "Default location: #{server.default_location}" if server.default_location
        put "Environment: " + server.environment_variables.map { |n, v| "#{n}=#{v}" }.join(" ")
        unless server.commands.empty?
          section("Commands:") do
            server.commands.each { |c| render_command(c) }
          end
        end
      end
      result
    end

    def render_environment(environment)
      section("Environment: #{environment.name}", ("(No servers)" if environment.servers.empty?)) do
        if environment.servers.any?
          environment.servers.each { |s| render_server(s) }
        end
      end
      result
    end

    def render_project(project)
      section("Project: #{project.name}", ("(No environments)" if project.environments.empty?)) do
        if project.environments.any?
          project.environments.each { |e| render_environment(e) }
        end
      end
      put
      result
    end

    def render_config(config)
      if config.projects.any?
        config.projects.each { |p| render_project(p) }

        put
        put "Default destination: #{config.default_destination}" if config.default_destination
      else
        put "There are no projects yet..."
      end
      result
    end

    private


    def section(title = nil, note = nil)
      put [title, note].compact.join(" ") if title
      @indent_level += 1
      yield
      @indent_level -= 1
    end

    def put(str = nil)
      @result += "  " * @indent_level + str.to_s.chomp + "\n"
    end
  end
end

