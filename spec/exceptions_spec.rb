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
      block: #<Proc:.*:\d+>
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

  context "when an exception is rescued and re-raised" do
    it "doesn't capture and store power trace again" do
      exception = nil

      begin
        begin
          FooWithRuntimeException.new.first_call
        rescue => exception
          raise exception
        end
      rescue
      end

      expect(exception.stored_power_trace.to_s(colorize: false)).to match(expected_power_trace)
    end
  end

  it "doesn't affect exception's original backtrace" do
    expected_backtrace.each_with_index do |trace_regex, i|
      expect(exception.backtrace[i]).to match(trace_regex)
    end
  end

  it "inserts power_trace to exceptions" do
    expect(exception.stored_power_trace.to_s(colorize: false)).to match(expected_power_trace)
  end

  context "with extra_info_indent: Int" do
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
          block: #<Proc:.*:\d+>
.*:\d+:in `second_call'
        \(Arguments\)
          num: 20/
    end
    it "indents the extra information according to the given value" do
      expect(exception.stored_power_trace.to_s(colorize: false, extra_info_indent: 8)).to match(expected_power_trace)
    end
  end

  context "when PowerTrace.replace_backtrace = true" do
    around do |example|
      begin
        PowerTrace.replace_backtrace = true
        PowerTrace.colorize_backtrace = false

        example.run
      ensure
        PowerTrace.replace_backtrace = false
        PowerTrace.colorize_backtrace = true
      end
    end
    it "replaces error's backtrace" do
      expect(exception.backtrace.join("\n")).to match(expected_power_trace)
    end

    context "when there's an error" do
      before do
        allow_any_instance_of(StandardError).to receive(:set_backtrace).and_raise("Foo Error")
      end

      let(:expected_backtrace) do
        [
          /.*:\d+:in `forth_call'/,
          /.*:\d+:in `block in second_call'/,
          /.*:\d+:in `third_call_with_block'/,
          /.*:\d+:in `second_call'/,
          /.*:\d+:in `first_call'/,
        ]
      end

      it "doesn't break anything" do
        expect do
          silent_io do
            exception
          end
        end.not_to raise_error
      end

      it "displays the error to help users file an issue" do
        result = capture_io do
          exception
        end

        expect(result[:stdout]).to match(/Foo Error/)
        expect(result[:stdout]).to match(/there's a bug in power_trace, please open an issue at https:\/\/github.com\/st0012\/power_trace/)
      end
    end
  end
end
