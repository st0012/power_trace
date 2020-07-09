module PowerTrace
  class Entry
    attr_reader :frame, :filepath, :line_number, :receiver

    def initialize(frame)
      @frame = frame
      @filepath = frame.eval("__FILE__")
      @line_number = frame.eval("__LINE__")
      @receiver = frame.receiver
    end

    def to_payload
      Output::Payload.init({
        target: nil,
        receiver: @receiver,
        method_name: method_name,
        method_object: method,
        arguments: arguments,
        return_value: nil,
        filepath: @filepath,
        line_number: @line_number,
        defined_class: defined_class,
        trace: [],
        is_private_call?: is_private_call?,
        tp: nil
      })
    end

    def call_trace
      "#{filepath}:#{line_number}:in `#{method_name}"
    end

    def to_s(options = {})
      <<~MSG.chomp
        #{call_trace}
          <= #{arguments}
      MSG
    end
  end
end

require "power_trace/entries/method_entry"
require "power_trace/entries/block_entry"
