module Taketo
  module Constructs
  end
end

Dir.glob('taketo/constructs/*.rb').each do |c|
  require c
end
