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

Benchmark.benchmark do |bm|
  bench_proc = proc do
    3.times do
      bm.report do
        n.times do
          foo.first_call rescue nil
        end
      end
    end
  end

  puts "#{n} times - ruby #{RUBY_VERSION}"
  puts("Normal raise")

  bench_proc.call

  puts("====================================")
  puts("======= power_trace required =======")
  puts("====================================")

  require "power_trace"

  cases = [
    {
      replace_backtrace: false,
      trace_limit: 10
    },
    {
      replace_backtrace: false,
      trace_limit: 50
    },
    {
      replace_backtrace: true,
      trace_limit: 10
    },
    {
      replace_backtrace: true,
      trace_limit: 50
    }
  ]

  cases.each do |setup|
    PowerTrace.replace_backtrace = setup[:replace_backtrace]
    PowerTrace.trace_limit = setup[:trace_limit]

    message =
      if setup[:replace_backtrace]
        "Raise and replace backtrace (trace_limit: #{PowerTrace.trace_limit})"
      else
        "Raise and store power_trace (trace_limit: #{PowerTrace.trace_limit})"
      end

    puts(message)
    bench_proc.call
  end
end

# 1000 times - ruby 2.7.1
# Normal raise
#    0.001606   0.000091   0.001697 (  0.001692)
#    0.000953   0.000082   0.001035 (  0.001035)
#    0.000885   0.000099   0.000984 (  0.000984)
# ====================================
# ======= power_trace required =======
# ====================================
# Raise and store power_trace (trace_limit: 10)
#    0.197135   0.000762   0.197897 (  0.198118)
#    0.203479   0.001198   0.204677 (  0.205063)
#    0.197096   0.000967   0.198063 (  0.198181)
# Raise and store power_trace (trace_limit: 50)
#    1.187342   0.003542   1.190884 (  1.191932)
#    1.183849   0.003203   1.187052 (  1.187759)
#    1.196402   0.002802   1.199204 (  1.199782)
# Raise and replace backtrace (trace_limit: 10)
#    0.406225   0.001383   0.407608 (  0.408063)
#    0.405999   0.000521   0.406520 (  0.406738)
#    0.411041   0.001345   0.412386 (  0.412863)
# Raise and replace backtrace (trace_limit: 50)
#    1.528390   0.004480   1.532870 (  1.534161)
#    1.544761   0.003519   1.548280 (  1.549895)
#    1.387785   0.004530   1.392315 (  1.393240)

