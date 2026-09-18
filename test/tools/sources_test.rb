# frozen_string_literal: true

require_relative "../test_helper"

# What each source tool does with what it is given, and what it says back.
class SourceToolsTest < Minitest::Test
  SOURCES = [
    { "handle" => "website", "kind" => "site", "name" => "Example", "address" => "/anywaye/support/website", "excluded_paths" => [] },
    { "handle" => "docs", "kind" => "corpus", "name" => "Documentation", "address" => "/anywaye/support/docs", "excluded_paths" => ["/internal"] }
  ].freeze

  PAGES = [
    { "reference" => "/pricing", "title" => "Pricing" },
    { "reference" => "/features", "title" => "Features" }
  ].freeze

  SEARCH = [
    { "reference" => "/pricing", "title" => "Pricing", "snippet" => "Plans start at..." }
  ].freeze

  def tool(klass, client: default_client)
    klass.new(client: client)
  end

  def default_client
    FakeClient.new(
      sources: { %w[anywaye support] => SOURCES },
      pages: {
        %w[anywaye support website] => PAGES,
        %w[anywaye support website /pricing] => { "title" => "Pricing", "content" => "# Pricing\n\n$9/mo.", "source" => "website" }
      },
      search_results: { %w[anywaye support website] => SEARCH }
    )
  end

  # -- list_sources --------------------------------------------------------

  def test_list_sources_names_each_source
    answer = tool(Ask::AnyChat::MCP::Tools::ListSources)
             .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "Example at /anywaye/support/website"
    assert_includes answer, "Documentation at /anywaye/support/docs"
  end

  def test_list_sources_shows_excluded_paths
    answer = tool(Ask::AnyChat::MCP::Tools::ListSources)
             .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "set aside: /internal"
  end

  def test_list_sources_says_when_there_are_none
    client = FakeClient.new(sources: { %w[anywaye support] => [] })
    answer = tool(Ask::AnyChat::MCP::Tools::ListSources, client: client)
             .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_equal "This agent has no sources yet.", answer
  end

  # -- get_source ----------------------------------------------------------

  def test_get_source_shows_name_kind_and_address
    answer = tool(Ask::AnyChat::MCP::Tools::GetSource)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website" })

    assert_includes answer, "Example (site)"
    assert_includes answer, "/anywaye/support/website"
  end

  def test_get_source_says_all_pages_when_none_excluded
    answer = tool(Ask::AnyChat::MCP::Tools::GetSource)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website" })

    assert_includes answer, "All pages available"
  end

  def test_get_source_lists_excluded_paths
    answer = tool(Ask::AnyChat::MCP::Tools::GetSource)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "docs" })

    assert_includes answer, "Set aside: /internal"
  end

  # -- browse_pages --------------------------------------------------------

  def test_browse_pages_lists_each_page
    answer = tool(Ask::AnyChat::MCP::Tools::BrowsePages)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website" })

    assert_includes answer, "/pricing — Pricing"
    assert_includes answer, "/features — Features"
  end

  def test_browse_pages_shows_count
    answer = tool(Ask::AnyChat::MCP::Tools::BrowsePages)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website" })

    assert_includes answer, "2 pages"
  end

  def test_browse_pages_says_when_empty
    client = FakeClient.new(
      sources: { %w[anywaye support] => SOURCES },
      pages: { %w[anywaye support website] => [] }
    )
    answer = tool(Ask::AnyChat::MCP::Tools::BrowsePages, client: client)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website" })

    assert_equal "This source has no pages yet.", answer
  end

  # -- read_page -----------------------------------------------------------

  def test_read_page_returns_title_and_content
    answer = tool(Ask::AnyChat::MCP::Tools::ReadPage)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website", "reference" => "/pricing" })

    assert_includes answer, "Pricing"
    assert_includes answer, "$9/mo."
  end

  # -- search_pages --------------------------------------------------------

  def test_search_returns_references_and_snippets
    answer = tool(Ask::AnyChat::MCP::Tools::SearchPages)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website", "query" => "pricing" })

    assert_includes answer, "/pricing — Pricing: Plans start at..."
  end

  def test_search_says_when_nothing_found
    client = FakeClient.new(
      sources: { %w[anywaye support] => SOURCES },
      search_results: { %w[anywaye support website] => [] }
    )
    answer = tool(Ask::AnyChat::MCP::Tools::SearchPages, client: client)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "website", "query" => "pricing" })

    assert_equal "Nothing found for pricing.", answer
  end

  # -- error handling ------------------------------------------------------

  def test_a_refusal_comes_back_as_text
    answer = tool(Ask::AnyChat::MCP::Tools::GetSource)
             .call({ "workspace" => "anywaye", "agent" => "support", "source" => "nope" })

    assert_includes answer, "Error:"
  end

  def test_a_missing_argument_names_what_was_wanted
    answer = tool(Ask::AnyChat::MCP::Tools::ReadPage)
             .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "missing required argument"
  end
end
