require 'taketo/constructs'

module Taketo
  class ConstructsFactory

    def create(type, *args)
      send("create_#{type}", *args)
    end

    def create_config
      Constructs::Config.new
    end

    def create_project(*args)
      Constructs::Project.new(*args)
    end

    def create_environment(*args)
      Constructs::Environment.new(*args)
    end

    def create_server(*args)
      Constructs::Server.new(*args)
    end

    def create_group(*args)
      Constructs::Group.new(*args)
    end

    def create_command(*args)
      Constructs::Command.new(*args)
    end
  end
end

