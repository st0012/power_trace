class Foo
  def first_call
    second_call(20)
  end

  def second_call(num)
    third_call_with_block do |ten|
      forth_call(num, ten)
    end
  end

  def third_call_with_block(&block)
    @ivar1 = 10; @ivar2 = 20

    yield(10)
  end

  def forth_call(num1, num2)
    puts(power_trace.to_s(colorize: false))
  end
end

class FooWithRuntimeException < Foo
  def forth_call(num1, num2)
    raise "Foo Error"
  end
end
