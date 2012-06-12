require 'taketo/constructs'

module Taketo
  class ConstructsFactory
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
  end
end

