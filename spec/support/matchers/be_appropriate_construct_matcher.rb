require 'taketo/dsl'

RSpec::Matchers.define :be_appropriate_construct do |construct, *args|
  chain(:under) do |enclosing_scope|
    @enclosing_scope = enclosing_scope
  end

  chain(:with_block) do |with_block|
    @blk = Proc.new {} if with_block
  end

  match do |actual|
    unless @enclosing_scope
      raise ArgumentError, "#under must be called to set enclosing scope"
    end

    @result = true
    dsl(@enclosing_scope) do |c|
      begin
        if @blk
          c.send(construct, *args, &@blk)
        else
          c.send(construct, *args)
        end
      rescue Taketo::DSL::ScopeError => e
        @result = false
      rescue
        #nothing
      end
    end
    @result
  end

  description do
    "#{name_to_sentence} ##{construct}(#{args.join(", ")}) under #{@enclosing_scope.inspect}"
  end

  failure_message_for_should do |actual|
    "expected construct #{construct} to be appropriate under #{@enclosing_scope.inspect} scope"
  end

  failure_message_for_should_not do |actual|
    "expected construct #{construct} not to be appropriate under #{@enclosing_scope.inspect} scope"
  end
end

