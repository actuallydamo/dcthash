# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  SimpleCov.minimum_coverage line: 100, branch: 100
end

require "dcthash"
require "json"
require "rmagick"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
