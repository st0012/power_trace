RSpec.describe PowerTrace do
  let(:expected_output) do
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

  it "prints traces correctly" do
    expect do
      Foo.new.first_call
    end.to output(expected_output).to_stdout
  end
end
