RSpec::Matchers.define :have_accessor do |accessor|
  match do |construct|
    construct.send("#{accessor}=", :foo)
    construct.send(accessor) == :foo
  end
end

