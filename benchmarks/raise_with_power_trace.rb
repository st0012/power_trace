require 'benchmark'
lib = File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

n = 1_000

class Foo
  def first_call
    second_call(20)
  end

  def second_call(num)
    third_call_with_block do |ten|
      forth_call(num, ten)
    end
  end

  def third_call_with_block(&block)
    yield(10)
  end

  def forth_call(num1, num2)
    raise "Foo Error"
  end
end

foo = Foo.new

def normal_raise(foo)
  foo.first_call
end

def raise_with_power_rspec_trace(foo)
  foo.first_call
end

def raise_with_replace_backtrace(foo)
  foo.first_call
end

Benchmark.benchmark do |bm|
  puts "#{n} times - ruby #{RUBY_VERSION}"

  puts("Normal raise")
  3.times do
    bm.report do
      n.times do
        foo.first_call rescue nil
      end
    end
  end

  require "power_trace"
  puts("==== power_trace required ====")
  PowerTrace.power_rspec_trace = true

  puts("Raise and store power_trace")

  3.times do
    bm.report do
      n.times do
        foo.first_call rescue nil
      end
    end
  end

  PowerTrace.replace_backtrace = true

  puts("Raise and replace backtrace")

  3.times do
    bm.report do
      n.times do
        foo.first_call rescue nil
      end
    end
  end
end

# 1000 times - ruby 2.7.1
# Normal raise
#    0.001719   0.000079   0.001798 (  0.001794)
#    0.000896   0.000096   0.000992 (  0.000991)
#    0.000904   0.000091   0.000995 (  0.000995)
# ==== power_trace required ====
# Raise and store power_trace
#    1.152806   0.001213   1.154019 (  1.154360)
#    1.159276   0.000568   1.159844 (  1.160036)
#    1.189207   0.000889   1.190096 (  1.190849)
# Raise and replace backtrace
#    1.293883   0.001389   1.295272 (  1.295620)
#    1.241478   0.000743   1.242221 (  1.242743)
#    1.269536   0.001056   1.270592 (  1.270974)
