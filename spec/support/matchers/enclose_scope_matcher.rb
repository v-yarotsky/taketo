RSpec::Matchers.define :enclose_scope do |expected_scope|
  chain(:under) do |scope_variants|
    @external_scope_variants = scope_variants
  end

  match do |actual|
    @result = true
    @external_scope_variants.each do |external_scope_variant|
      dsl(external_scope_variant || scopes[:config]) do |c|
        @result &= !c.send(:current_scope?, expected_scope)
        c.send(expected_scope, :foo) do
          @result &= c.send(:current_scope?, expected_scope)
        end
        @result &= !c.send(:current_scope?, expected_scope)
      end
    end
    @result
  end

  description do
    msg = "enclose scope #{expected_scope}"
    msg += " under #{@external_scope_variants.inspect}" if @external_scope_variants
    msg
  end
end

