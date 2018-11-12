require 'bundler/setup'
require 'timecop'
require 'knock_knock'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

KnockKnock.configure do |config|
  config.logger = Logger.new($stdout, level: 3)
end
