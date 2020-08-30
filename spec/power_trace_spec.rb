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
      block: #<Proc:.*:\d+>
    \(Instance Variables\)
      @ivar1: 10
      @ivar2: 20
.*:\d+:in `second_call'
    \(Arguments\)
      num: 20/
  end

  it "prints traces correctly" do
    expect do
      Foo.new.first_call
    end.to output(expected_output).to_stdout
  end

  describe ".integrations=" do
    it "takes a single option" do
      expect(PowerTrace).to receive(:require)

      PowerTrace.integrations = :rspec

      expect(PowerTrace.integrations).to eq([:rspec])
    end

    it "takes multiple options" do
      expect(PowerTrace).to receive(:require).twice

      PowerTrace.integrations = [:rspec, :rails]

      expect(PowerTrace.integrations).to match_array([:rspec, :rails])
    end

    it "takes string options too" do
      expect(PowerTrace).to receive(:require)

      PowerTrace.integrations = "rspec"

      expect(PowerTrace.integrations).to eq([:rspec])
    end

    it "raises error when receiving unexpected option" do
      expect do
        PowerTrace.integrations = :foo
      end.to raise_error("foo is not a supported integration, only [:rails, :rspec, :minitest] is allowed.")
    end
  end
end
