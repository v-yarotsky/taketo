module Taketo
  module Commands
  end
end

Dir.glob(File.expand_path('../commands/*.rb', __FILE__)).each { |c| require c }
