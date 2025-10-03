Gem::Specification.new do |spec|
  spec.name          = "orionx-sdk-ruby"
  spec.version       = "1.0.3"
  spec.authors       = ["PabloB07"]
  spec.email         = ["pablob0798@gmail.com"]

  spec.summary       = "Unofficial OrionX SDK for Ruby"
  spec.description   = "A comprehensive Ruby SDK for the OrionX cryptocurrency exchange API with debug capabilities, error handling, and comprehensive examples."
  spec.homepage      = "https://github.com/PabloB07/orionx-sdk-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    Dir["{lib,spec}/**/*", "*.md", "*.txt", "Gemfile", "Rakefile"]
  end
  
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-net_http", "~> 3.0"
  spec.add_dependency "logger", "~> 1.5"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "webmock", "~> 3.18"
end