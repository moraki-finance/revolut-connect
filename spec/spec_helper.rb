# frozen_string_literal: true

if ENV["COVERAGE_DIR"]
  require "simplecov"
  SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
  SimpleCov.start
end

require "bundler/setup"
require "webmock/rspec"
require "dotenv"
Dotenv.load(".env.test")
require "dotenv/autorestore"
require "revolut"
Bundler.require(:default, :development, :test)

Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Timecop.freeze(Time.now)
  end

  config.after(:each) do
    Timecop.return
  end

  config.include AuthHelpers
  config.include ResourceHelpers
end

RSpec::Matchers.define :eq_as_json do |expected_result|
  match do |actual_result|
    actual_result.to_json == expected_result.to_json
  end
end
