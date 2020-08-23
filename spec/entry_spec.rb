require "spec_helper"
require "model"

RSpec.describe PowerTrace::Entry do
  let(:frame) do
    f = spy(source_location: [], receiver: nil, local_variables: [:var])
    allow(f).to receive(:local_variable_get).and_return(value)
    f
  end
  subject do
    described_class.new(frame)
  end

  describe "#value_to_string" do
    context "String" do
      let(:value) { "string" }

      it "wraps value in quotes" do
        expect(subject.locals_string).to match('"string"')
      end

      context "with long value" do
        let(:value) { "s" * 20 }

        it "truncates it to meet the line limit" do
          expect(subject.locals_string(line_limit: 10)).to match('"sssssss..."')
        end
      end
    end

    context "Symbol" do
      let(:value) { :string }

      it "appends a colon" do
        expect(subject.locals_string).to match(':string')
      end
    end

    context "Hash" do
      let(:value) { { foo: "bar", bar: "baz" } }

      it "wraps the value with {}" do
        expect(subject.locals_string).to match('var: {:foo=>"bar", :bar=>"baz"}')
      end

      context "with long value" do
        let(:value) { { foo: "ssssss", bar: "yyyyyyyy" } }

        it "truncates it to meet the line limit" do
          expect(subject.locals_string(line_limit: 30)).to match('var: {:foo=>"ssssss", :bar=>"yy...}')
        end
      end
    end

    context "Array" do
      let(:value) { %w(foo bar baz) }

      it "wraps the value with []" do
        expect(subject.locals_string).to match('var: \["foo", "bar", "baz"\]')
      end

      context "with long value" do
        let(:value) { %w(foo bar baz 123) }

        it "truncates it to meet the line limit" do
          expect(subject.locals_string(line_limit: 20)).to match('var: \["foo", "bar", "...\]')
        end
      end
    end
  end
end
