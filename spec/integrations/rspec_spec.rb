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
        \(Instance Variables\)
          @ivar1: 10
          @ivar2: 20
.*:\d+:in `second_call'
        \(Arguments\)
          num: 20/
    end

    context "with PowerTrace.integrations = :rspec" do
      around do |example|
        with_integration(:rspec) do
          example.run
        end
      end

      it "replaces backtrace with power_trace" do
        expect(presenter.formatted_backtrace.join("\n")).to match(expected_output)
      end

      context "when there's an error processing backtrace" do
        before do
          allow(exception).to receive(:stored_power_trace).and_raise("Foo Error")
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
          formatted_backtrace = nil

          expect do
            silent_io do
              formatted_backtrace = presenter.formatted_backtrace
            end
          end.not_to raise_error

          expected_backtrace.each_with_index do |trace_regex, i|
            expect(formatted_backtrace[i]).to match(trace_regex)
          end
        end

        it "displays the error to help users file an issue" do
          result = capture_io do
            presenter.formatted_backtrace
          end

          expect(result[:stdout]).to match(/Foo Error/)
          expect(result[:stdout]).to match(/there's a bug in power_trace, please open an issue at https:\/\/github.com\/st0012\/power_trace/)
        end
      end
    end
  end
end
