require "spec_helper"
require "action_dispatch"
require "active_support/logger"

RSpec.describe ActionDispatch::DebugExceptions do
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

  let(:wrapper) { ActionDispatch::ExceptionWrapper.new(cleaner, exception) }
  let(:io) { StringIO.new }
  let(:logger) { ActiveSupport::Logger.new(io) }
  let(:request) { double(logger: logger) }

  subject { described_class.new({}) }

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

  describe "#log_error" do
    it "logs power traces as expected" do
      subject.send(:log_error, request, wrapper)

      expect(io.string).to match(expected_output)
    end
  end
end
