RSpec::Matchers.define :have_accessor do |*args|
  accessor = args.shift or raise ArgumentError, "No accessor name supplied"
  value = args.shift || :foo

  match do |construct|
    construct.send("#{accessor}=", value)
    construct.send(accessor) == value
  end
end

