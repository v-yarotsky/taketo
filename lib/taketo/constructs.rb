module Taketo
  module Constructs
  end
end

Dir.glob(File.expand_path('../constructs/*.rb', __FILE__)).each { |c| require c }
