require_relative 'lib/power_trace/version'

Gem::Specification.new do |spec|
  spec.name          = "power_trace"
  spec.version       = PowerTrace::VERSION
  spec.authors       = ["st0012"]
  spec.email         = ["stan001212@gmail.com"]

  spec.summary       = %q{power_trace provides you more powerful backtraces.}
  spec.description   = %q{power_trace provides you more powerful backtraces.}
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
  spec.add_dependency "pry"
  spec.add_dependency "pry-stack_explorer"
end
