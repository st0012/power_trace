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

  let(:expected_output) do
/.*:9:in `block in second_call'
  <= {ten: 10, num: 20}
.*:14:in `third_call_with_block'
  <= {block: #<Proc:.*@.*:8>}
.*:8:in `second_call'
  <= {num: 20}/
  end

  it "prints traces correctly" do
    expect do
      Foo.new.first_call
    end.to output(expected_output).to_stdout
  end
end
