RSpec::Matchers.define :enclose_scope do |expected_scope|
  chain(:under) do |scope|
    @external_scope = scope
  end

  match do |actual|
    @result = true
    dsl(@external_scope || [:config]) do |c|
      @result &= !c.send(:current_scope?, expected_scope)
      c.send(expected_scope, :foo) do
        @result &= c.send(:current_scope?, expected_scope)
      end
      @result &= !c.send(:current_scope?, expected_scope)
    end
    @result
  end
end

