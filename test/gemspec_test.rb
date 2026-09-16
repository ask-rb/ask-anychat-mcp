# frozen_string_literal: true

require_relative "test_helper"

class GemspecTest < Minitest::Test
  def test_gemspec_is_valid
    spec = Gem::Specification.load(File.expand_path("../ask-anychat-mcp.gemspec", __dir__))

    assert spec, "Could not load gemspec"
    assert_kind_of Gem::Specification, spec
    assert spec.name.to_s.start_with?("ask-")
    assert_operator spec.version.to_s, :>, "0"
  end

  def test_the_executable_is_declared
    spec = Gem::Specification.load(File.expand_path("../ask-anychat-mcp.gemspec", __dir__))

    assert_includes spec.executables, "ask-anychat-mcp"
  end

  def test_the_executable_is_present_and_runnable
    path = File.expand_path("../bin/ask-anychat-mcp", __dir__)

    assert_path_exists path, "bin/ask-anychat-mcp is missing"
    assert File.executable?(path), "bin/ask-anychat-mcp is not executable"
  end
end
