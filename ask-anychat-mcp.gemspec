# frozen_string_literal: true

require_relative "lib/ask/anychat/mcp/version"

Gem::Specification.new do |spec|
  spec.name = "ask-anychat-mcp"
  spec.version = Ask::AnyChat::MCP::VERSION
  spec.authors = ["Kaka Ruto"]
  spec.email = ["kaka@myrrlabs.com"]

  spec.summary = "MCP server for Anychat"
  spec.description = "A minimal MCP (Model Context Protocol) server that exposes the " \
                     "agents an Anychat workspace owns as callable tools over stdio — " \
                     "list them, read one, bring a new one into being, change one, or " \
                     "retire one. Designed for clients that speak MCP (ZCode, Claude " \
                     "Code, and the like). The tool shell (name, schema, call) lives " \
                     "here, wrapping ask-anychat; the API client itself is that gem's."

  spec.homepage = "https://github.com/ask-rb/ask-anychat-mcp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.bindir = "bin"
  spec.executables = ["ask-anychat-mcp"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ask-anychat", ">= 0.2.1"
  spec.add_dependency "ask-mcp", ">= 0.5.0"

  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "rake", "~> 13.0"
end
