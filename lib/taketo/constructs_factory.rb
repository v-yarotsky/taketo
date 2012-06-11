require 'taketo/constructs'

module Taketo
  class ConstructsFactory
    include Constructs

    def create_config
      Config.new
    end

    def create_project(*args)
      Project.new(*args)
    end

    def create_environment(*args)
      Environment.new(*args)
    end

    def create_server(*args)
      Server.new(*args)
    end
  end
end

