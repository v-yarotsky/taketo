module Taketo
  module Constructs
    class Server
      attr_reader :name
      attr_accessor :host, :port, :username, :default_location, :environment
      
      def initialize(name)
        @name = name
      end
    end
  end
end

