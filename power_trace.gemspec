require_relative 'lib/power_trace/version'

Gem::Specification.new do |spec|
  spec.name          = "power_trace"
  spec.version       = PowerTrace::VERSION
  spec.authors       = ["st0012"]
  spec.email         = ["stan001212@gmail.com"]

  spec.summary       = %q{power_trace provides you a more powerful backtrace.}
  spec.description   = %q{Backtrace (Stack traces) are essential information for debugging our applications. However, they only tell us what the program did, but don't tell us what it had (the arguments, local variables...etc.). So it's very often that we'd need to visit each call site, rerun the program, and try to print out the variables. To me, It's like the Google map's navigation only tells us the name of the roads, but not showing us the map along with them.

So I hope to solve this problem by adding some additional runtime info to the backtrace, and save us the work to manually look them up.}

  spec.homepage      = "https://github.com/st0012/power_trace"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "binding_of_caller", "~> 0.8.0"

  spec.add_development_dependency "pry"
end
