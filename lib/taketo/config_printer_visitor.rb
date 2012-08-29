require 'taketo/config_visitor'

module Taketo
  class ConfigPrinterVisitor < ConfigVisitor
    def initialize
      @indent_level = 0
      @result = ""
    end

    visit Taketo::Constructs::Config do |config|
      indent(0) do
        if config.has_projects?
          put "Default destination: #{config.default_destination}" if config.default_destination
        else
          put "There are no projects yet..."
        end
      end
    end

    visit Taketo::Constructs::Project do |project|
      put
      indent(0) do
        put "Project: #{project.name}"
        indent { put "(No environments)" unless project.has_environments? }
      end
    end

    visit Taketo::Constructs::Environment do |environment|
      indent(1) do
        put "Environment: #{environment.name}"
        indent { put "(No servers)" unless environment.has_servers? }
      end
    end

    visit Taketo::Constructs::Server do |server|
      indent(2) do
        put "Server: #{server.name}"
        indent do
          put "Host: #{server.host}"
          put "Port: #{server.port}" if server.port
          put "User: #{server.username}" if server.username
          put "Default location: #{server.default_location}" if server.default_location
          put "Environment: " + server.environment_variables.map { |n, v| "#{n}=#{v}" }.join(" ")
          indent { put "(No commands)" unless server.has_commands? }
        end
      end
    end

    visit Taketo::Constructs::Command do |command|
      indent(4) { put command.name.to_s + (" - " + command.description if command.description).to_s }
    end

    def result
      @result.chomp
    end

    def indent(level = nil)
      @first_indent ||= level || @indent_level
      level ? @indent_level = level - @first_indent : @indent_level += 1
      yield
    end

    def put(str = nil)
      @result += ("  " * @indent_level + str.to_s).rstrip.chomp + "\n"
    end
  end
end

