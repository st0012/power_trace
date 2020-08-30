require "spec_helper"
require "action_dispatch/middleware/exception_wrapper"
require "active_support/backtrace_cleaner"

RSpec.describe ActionDispatch::ExceptionWrapper do
  before do
    PowerTrace.power_rails_trace = true
  end
  let(:exception) do
    begin
      FooWithRuntimeException.new.first_call
    rescue => e
      e
    end
  end
  let(:cleaner) do
    cleaner = ActiveSupport::BacktraceCleaner.new
    cleaner.add_silencer { |line| !line.match?(/power_trace/) }
    cleaner
  end

  subject { described_class.new(cleaner, exception) }

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
      block: #<Proc:.*:\d+>
    \(Instance Variables\)
      @ivar1: 10
      @ivar2: 20
.*:\d+:in `second_call'
    \(Arguments\)
      num: 20/
  end

  describe "#full_power_trace" do
    let(:traces) { subject.full_power_trace }

    it "returns power traces" do
      expect(traces.join("\n")).to match(expected_output)
      expect(traces.count).to eq(50)
    end
  end

  describe "#application_power_trace" do
    let(:traces) { subject.application_power_trace }

    it "returns power traces" do
      expect(traces.join("\n")).to match(expected_output)
      expect(traces.count).to eq(9)
    end
  end

  describe "#framework_power_trace" do
    let(:not_expected_output) do
      expected_output
    end

    let(:traces) { subject.framework_power_trace }

    it "returns power traces" do
      expect(traces.join("\n")).not_to match(not_expected_output)
      expect(traces.count).to eq(41)
    end
  end
end
