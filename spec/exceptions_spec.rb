RSpec.describe PowerTrace do
  let(:expected_power_trace) do
/.*:\d+:in `forth_call'
    \(Arguments\)
    num1: 20
    num2: 10
.*:\d+:in `block in second_call'
    \(Locals\)
    ten: 10
    num: 20
.*:\d+:in `third_call_with_block'
    \(Arguments\)
    block: #<Proc:.*@.*:\d+>
.*:\d+:in `second_call'
    \(Arguments\)
    num: 20/
  end

  let(:expected_backtrace) do
    [
      /.*:\d+:in `forth_call'/,
      /.*:\d+:in `block in second_call'/,
      /.*:\d+:in `third_call_with_block'/,
      /.*:\d+:in `second_call'/,
      /.*:\d+:in `first_call'/,
      /.*:\d+:in `block \(2 levels\) in <top \(required\)>'/
    ]
  end

  let(:exception) do
    exception = nil

    begin
      FooWithRuntimeException.new.first_call
    rescue => exception
    end

    exception
  end

  it "doesn't affect exception's original backtrace" do
    expected_backtrace.each_with_index do |trace_regex, i|
      expect(exception.backtrace[i]).to match(trace_regex)
    end
  end

  it "inserts power_trace to exceptions" do
    expect(exception.power_trace.to_s(colorize: false)).to match(expected_power_trace)
  end
end
