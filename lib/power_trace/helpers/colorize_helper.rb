module PowerTrace
  module ColorizeHelper
    COLOR_CODES = {
      green: 10,
      yellow: 11,
      blue: 12,
      megenta: 13,
      cyan: 14,
      orange: 214
    }

    RESET_MARK = "\u001b[0m"

    COLOR_CODES.each do |color, code|
      define_method "#{color}_color" do |str|
        color_mark = "\u001b[38;5;#{code}m"
        "#{color_mark}#{str}#{RESET_MARK}"
      end
    end
  end
end
