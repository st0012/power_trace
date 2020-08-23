require "minitest"

RSpec.describe "Minitest" do
  def run_example(tu, flags = %w[--seed 42])
    options = Minitest.process_args flags

    output = $stdout

    reporter = Minitest::CompositeReporter.new
    reporter << Minitest::SummaryReporter.new(output, options)
    reporter << Minitest::ProgressReporter.new(output, options)

    reporter.start

    yield(reporter) if block_given?

    Minitest::Runnable.runnables.delete tu

    tu.run reporter, options

    reporter.report
  end

  class FakeTest < Minitest::Test
    def test_something
      assert true
    end

    def test_error
      FooWithRuntimeException.new.first_call
    end
  end

  let(:expected_output) do
/1\) Error:
FakeTest#test_error:
RuntimeError: Foo Error
    .*:\d+:in `forth_call'
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

  context "with PowerTrace.power_minitest_trace = false" do
    let(:expected_output) do
      /1\) Error:
FakeTest#test_error:
RuntimeError: Foo Error
  .*:\d+:in `forth_call'
  .*:\d+:in `block in second_call'
  .*:\d+:in `third_call_with_block'
  .*:\d+:in `second_call'
  .*:\d+:in `first_call'
  .*:\d+:in `test_error'

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips/
    end

    before do
      PowerTrace.power_minitest_trace = false
    end

    it "doesn't do anything" do
      result = capture_io do
        run_example(FakeTest)
      end
      expect(result[:stdout]).to match(expected_output)
    end
  end


  context "with PowerTrace.power_minitest_trace = true" do
    around do |example|
      begin
        PowerTrace.power_minitest_trace = true
        PowerTrace.colorize_backtrace = false

        example.run
      ensure
        PowerTrace.power_minitest_trace = false
        PowerTrace.colorize_backtrace = true
      end
    end

    it "replaces backtrace with power_trace" do
      result = capture_io do
        run_example(FakeTest)
      end
      expect(result[:stdout]).to match(expected_output)
    end

    context "when there's an error processing backtrace" do
      before do
        allow_any_instance_of(PowerTrace::Stack).to receive(:to_backtrace).and_raise("Foo Error")
      end

      let(:expected_output) do
        /1\) Error:
FakeTest#test_error:
RuntimeError: Foo Error
    .*:\d+:in `forth_call'
    .*:\d+:in `block in second_call'
    .*:\d+:in `third_call_with_block'
    .*:\d+:in `second_call'
    .*:\d+:in `first_call'
    .*:\d+:in `test_error'

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips/
      end

      it "doesn't break anything" do
        result = capture_io do
          run_example(FakeTest)
        end

        expect(result[:stdout]).to match(expected_output)
      end

      it "displays the error to help users file an issue" do
        result = capture_io do
          run_example(FakeTest)
        end

        expect(result[:stdout]).to match(/Foo Error/)
        expect(result[:stdout]).to match(/there's a bug in power_trace, please open an issue at https:\/\/github.com\/st0012\/power_trace/)
      end
    end
  end
end
