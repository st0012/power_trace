# power_trace

![Ruby](https://github.com/st0012/power_trace/workflows/Ruby/badge.svg) [![Gem Version](https://badge.fury.io/rb/power_trace.svg)](https://badge.fury.io/rb/power_trace) [![codecov](https://codecov.io/gh/st0012/power_trace/branch/master/graph/badge.svg)](https://codecov.io/gh/st0012/power_trace)

Backtrace (Stack traces) are essential information for debugging our applications. However, they only tell us what the program did, but don't tell us what it had (the arguments, local variables...etc.). So it's very often that we'd need to visit each call site, rerun the program, and try to print out the variables. To me, It's like the Google map's navigation only tells us the name of the roads, but not showing us the map along with them.

So I hope to solve this problem by adding some additional runtime info to the backtrace, and save us the work to manually look them up.

**Please Don't Use It On Production**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'power_trace', group: [:test, :development]
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install power_trace
```

## Usage

### Use It With Rails

You can add more context to Rails' exception reporting with:

```ruby
# config/initializers/power_trace.rb

if defined?(PowerTrace)
  PowerTrace.power_rails_trace = true
end
```

Result:

**Before**
![normal rails error message](https://github.com/st0012/power_trace/blob/master/images/normal_rails_error.png)

**After**
![rails error message with config set to true](https://github.com/st0012/power_trace/blob/master/images/power_rails_error.png)



### Use It With RSpec

You can prettify RSpec's error messages with `power_trace` by adding:

```ruby
# spec/spec_helper.rb

require "power_trace"
PowerTrace.power_rspec_trace = true
```

Result:

**Before**
![normal rspec error message](https://github.com/st0012/power_trace/blob/master/images/normal_rspec_error.png)

**After**
![rspec error message with config set to true](https://github.com/st0012/power_trace/blob/master/images/power_trace_rspec_error.png)

### Use It With Minitest

You can also prettify Minitest's error messages with `power_trace` with:

```ruby
# test/test_helper.rb

require "power_trace"
PowerTrace.power_minitest_trace = true
```

Result:

**Before**
![normal minitest error message](https://github.com/st0012/power_trace/blob/master/images/normal_minitest_error.png)

**After**
![minitest error message with config set to true](https://github.com/st0012/power_trace/blob/master/images/power_minitest_error.png)

### Call `power_trace` directly

If you call `power_trace` directly, it'll return a `PowerTrace::Stack` instance that contains all the processed traces. You can then use it in 3 different ways:

- Print it directly
- Access each trace (`Entry` instance)
- Convert it into backtraces (an array of strings)

#### Print It Directly

You can use `puts(power_trace)` to print the beautiful output to stdout:

![print power_trace directly](https://github.com/st0012/power_trace/blob/master/images/print_directly.png)

It should look just like the normal `puts(caller)`, just colorized and with more helpful info.

#### Access Individual Entries

Except for the call site, each entry also contains rich information about the runtime context. You can build your own debugging tool with that information easily.

Every entry has these attributes:

- `filepath`
- `line_number`
- `receiver` - the receiver object
- `frame` - the call frame (`Binding`) object
- `locals` - local variables in that frame
- `arguments`
    - the method call's arguments
    - will be empty for `block` entries

#### Convert It Into Backtraces

You can do it by calling `power_trace.to_backtrace`. The major usage is to replace an exception object's backtrace like

```ruby
a_exception.set_backtrace(power_trace.to_backtrace)
```

I don't recommend using it like this for other purposes, though. Because by default, all entries will be color-encoded strings. Also, the embedded arguments/locals aren't easily parseable. For other uses, you should either print it directly or process the traces without calling `to_backtrace`.

#### Options

- `colorize` - to decide whether to colorize each entry in their string format. Default is `true`.
- `line_limit` - `power_trace` truncates every argument/local variable's value to avoid creating too much noise. Default is `100`
- `extra_info_indent` - 

By default, extra info sections (locals/arguments) are indented with `4` spaces. Like:

```
/Users/st0012/projects/power_trace/spec/fixtures.rb:23:in `forth_call'
    (Arguments)
      num1: 20
      num2: 10
```

You can change this indentation with the `extra_info_indent: Int` option. It's useful when you need to adjust the output from some formatting tools (like `RSpec` formatters).

### Use It With StandardError (Experimental)

If you set 

```ruby
PowerTrace.replace_backtrace = true
```

it will replace every `StandardError` exception's backtrace with the `power_trace.to_backtrace`. So most of the error traces you see will also contain the colorized environment information!

This is still an experimental feature for now, as it has a very wide impact on all the libraries and your own code. **Don't try this on production!!!!**

#### Get `power_trace` Manually From A StandardError Exception

If you think the above feature is too aggressive. You can access an exception object's enhanced backtrace manually with the `power_trace` method:

```ruby
begin
  perform_a_call
rescue => e
  e.stored_power_trace # <= like this
end
```

This feature doesn't require any flag to enable, as the information is added as an extra field and doesn't override anything.

## Inspirations & Helpful Tools

- [pretty_backtrace](https://github.com/ko1/pretty_backtrace)
- [pry-stack_explorer](https://github.com/pry/pry-stack_explorer)
- [tapping_device](https://github.com/st0012/tapping_device)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org/).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/st0012/power_trace](https://github.com/st0012/power_trace). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/%5BUSERNAME%5D/power_trace/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PowerTrace project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/%5BUSERNAME%5D/power_trace/blob/master/CODE_OF_CONDUCT.md).
