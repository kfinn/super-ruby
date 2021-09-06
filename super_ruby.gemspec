require_relative 'lib/super_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "super_ruby"
  spec.license       = "MIT"
  spec.version       = SuperRuby::VERSION
  spec.authors       = ["Kevin Finn"]
  spec.email         = ["superkevin@gmail.com"]
  
  spec.summary       = %q{Ruby compiler for the Super language}
  spec.homepage      = "https://github.com/kfinn/super_ruby"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kfinn/super_ruby"
  spec.metadata["changelog_uri"] = "https://github.com/kfinn/super_ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'tty-config', '~> 0.3.2'
  # spec.add_dependency "rails", "~> 6.1.4", ">= 6.1.4.1"
end
