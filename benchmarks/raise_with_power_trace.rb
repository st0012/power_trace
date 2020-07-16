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
#    0.002032   0.000093   0.002125 (  0.002119)
#    0.001131   0.000107   0.001238 (  0.001239)
#    0.001092   0.000100   0.001192 (  0.001192)
# ====================================
# ======= power_trace required =======
# ====================================
# Raise and store power_trace (trace_limit: 10)
#    0.157296   0.001807   0.159103 (  0.159504)
#    0.159911   0.000668   0.160579 (  0.160961)
#    0.152814   0.000493   0.153307 (  0.153658)
# Raise and store power_trace (trace_limit: 50)
#    0.228311   0.000649   0.228960 (  0.229264)
#    0.248271   0.001956   0.250227 (  0.257272)
#    0.229469   0.000923   0.230392 (  0.230822)
# Raise and replace backtrace (trace_limit: 10)
#    0.331577   0.000360   0.331937 (  0.332203)
#    0.354934   0.001634   0.356568 (  0.356939)
#    0.334688   0.001201   0.335889 (  0.336682)
# Raise and replace backtrace (trace_limit: 50)
#    0.557920   0.002530   0.560450 (  0.561101)
#    0.553058   0.001767   0.554825 (  0.555651)
#    0.560771   0.002160   0.562931 (  0.563613)

