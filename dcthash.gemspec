# frozen_string_literal: true

require_relative "lib/dcthash/version"

Gem::Specification.new do |spec|
  spec.name          = "dcthash"
  spec.version       = Dcthash::VERSION
  spec.license       = "MIT"
  spec.authors       = ["Damien Kingsley"]
  spec.email         = ["actuallydamo@gmail.com"]
  spec.summary       = "Generate and compare perceptual image hashes"
  spec.description   = "This is a perceptual image hash calculation and comparison tool."
  spec.description  += " This can be used to match compressed or resized images to each other."
  spec.homepage      = "https://github.com/actuallydamo/dcthash"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")
  spec.add_dependency("rmagick", "~> 4.0")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.files         = Dir["lib/**/*", "sig/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
