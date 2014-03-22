module Taketo
  module ConfigVisitors

    class PrinterVisitor < BaseVisitor
      include Support::Printer

      visit Config do |config|
        indent(0) do
          if config.has_nodes?(:project)
            put_optional "Default destination:", config.default_destination
          else
            put "There are no projects yet..."
          end
        end
      end

      visit Project do |project|
        put
        indent(0) do
          put "Project: #{project.name}"
          indent { put "(No environments)" unless project.has_nodes?(:environment) }
        end
      end

      visit Environment do |environment|
        indent(1) do
          put "Environment: #{environment.name}"
          indent { put "(No servers)" unless environment.has_nodes?(:server) }
        end
      end

      visit Server do |server|
        indent(2) do
          put "Server: #{server.name}"
          indent do
            put "Host: #{server.host}"
            put_optional "Port:", server.port
            put_optional "User:", server.username
            put_optional "Default location:", server.default_location
            put "Default command: #{server.default_command}"
            put "Environment: " + server.environment_variables.map { |n, v| "#{n}=#{v}" }.join(" ")
            put "Commands:" if server.commands.any?
            indent do
              server.commands.each do |command|
                put command.name.to_s + (" - " + command.description if command.description).to_s
              end
            end
          end
        end
      end
    end

  end
end

