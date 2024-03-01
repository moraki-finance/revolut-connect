# frozen_string_literal: true

require "bundler/setup"
require "webmock/rspec"
require "dotenv"
Dotenv.load(".env.test")
require "dotenv/autorestore"
require "revolut"
Bundler.require(:default, :development, :test)

if ENV["COVERAGE_DIR"]
  require "simplecov"
  require "simplecov-cobertura"
  SimpleCov.coverage_dir(File.join(ENV["COVERAGE_DIR"]))
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.start
end

Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include AuthHelpers
  config.include ResourceHelpers
end

RSpec::Matchers.define :eq_as_json do |expected_result|
  match do |actual_result|
    actual_result.to_json == expected_result.to_json
  end
end
