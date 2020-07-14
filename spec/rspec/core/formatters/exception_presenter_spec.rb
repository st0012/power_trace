module RSpec::Core
  RSpec.describe Formatters::ExceptionPresenter do
    def new_example(metadata = {})
      metadata = metadata.dup
      result = RSpec::Core::Example::ExecutionResult.new
      result.started_at = ::Time.now
      result.record_finished(metadata.delete(:status) { :passed }, ::Time.now)
      result.exception = Exception.new if result.status == :failed

      instance_double(RSpec::Core::Example,
                       :description             => "Example",
                       :full_description        => "Example",
                       :example_group           => group,
                       :execution_result        => result,
                       :location                => "",
                       :location_rerun_argument => "",
                       :metadata                => {
                         :shared_group_inclusion_backtrace => []
                       }.merge(metadata)
                     )
    end

    def group
      group = class_double "RSpec::Core::ExampleGroup", :description => "Group"
      allow(group).to receive(:parent_groups) { [group] }
      group
    end

    let(:exception) do
      exception = nil

      begin
        FooWithRuntimeException.new.first_call
      rescue => exception
      end

      exception
    end

    let(:example) { new_example }
    let(:presenter) { Formatters::ExceptionPresenter.new(exception, example) }

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
.*:\d+:in `second_call'
        \(Arguments\)
          num: 20/
    end

    context "with PowerTrace.power_rspec_trace = true" do
      around do |example|
        begin
          PowerTrace.power_rspec_trace = true
          PowerTrace.colorize_backtrace = false

          example.run
        ensure
          PowerTrace.power_rspec_trace = false
          PowerTrace.colorize_backtrace = true
        end
      end

      it "replaces backtrace with power_trace" do
        expect(presenter.formatted_backtrace.join("\n")).to match(expected_output)
      end
    end
  end
end
