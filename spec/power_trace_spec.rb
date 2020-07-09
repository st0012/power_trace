RSpec.describe PowerTrace do
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
      yield(10)
    end

    def forth_call(num1, num2)
      result = num1 + num2
      puts(power_trace)
    end
  end
  it "has a version number" do
    expect(PowerTrace::VERSION).not_to be nil
  end

  it "does something useful" do
    Foo.new.first_call
  end
end
