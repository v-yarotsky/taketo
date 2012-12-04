module Taketo
  class DestinationMatcher
    def initialize(servers)
      @servers = servers
    end

    def matches
      (path_matches + global_alias_matches).uniq
    end

    private

    def path_matches
      @servers.map(&:path)
    end

    def global_alias_matches
      @servers.map(&:global_alias).map(&:to_s).reject(&:empty?)
    end
  end
end

