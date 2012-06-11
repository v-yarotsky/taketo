module Taketo
  class SSHCommand
    extend Forwardable

    def_delegators :@server, :host, :port, :username, :default_location

    def initialize(server, options = {})
      @server = server
      @environment = @server.environment
    end
    
    def render(command = "bash")
      %Q[ssh -t #{port} #{username}#{host} "#{[location, environment, command].compact.join(" ")}"].gsub(/ +/, " ")
    end

    def host
      unless @server.host
        raise ArgumentError, "host for server #{@server.name} in #{@environment.name} is not defined!"
      end
      %Q["#{@server.host}"]
    end

    def port
      %Q[-p #{@server.port}] if @server.port
    end

    def username
      %Q["#{@server.username}"@] if @server.username
    end

    def location
      %Q[cd '#{@server.default_location}';] if @server.default_location
    end

    def environment
      %Q[RAILS_ENV=#{@environment.name}]
    end
  end
end

