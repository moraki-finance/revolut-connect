# frozen_string_literal: true

require_relative "lib/revolut/version"

Gem::Specification.new do |spec|
  spec.name = "revolut-connect"
  spec.version = Revolut::VERSION
  spec.authors = ["Martin Mochetti"]
  spec.email = ["martin.mochetti@gmail.com"]

  spec.summary = "Revolut non-official API connector"
  spec.description = "Revolut API connector for Ruby. This gem is not official and is not supported by Revolut. Use at your own risk."
  spec.homepage = "https://github.com/moraki-finance/revolut-connect"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moraki-finance/revolut-connect"
  spec.metadata["changelog_uri"] = "https://github.com/moraki-finance/revolut-connect/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", ">= 1"
  spec.add_dependency "faraday", ">= 1"
  spec.add_dependency "faraday-retry", ">= 1"
end
