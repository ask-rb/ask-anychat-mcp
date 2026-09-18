# frozen_string_literal: true

require_relative "test_helper"

# The wiring: what the server offers a client, and the contract every tool has
# to keep. A tool that is missing its description or its schema is a tool a
# model cannot choose correctly.
class MCPTest < Minitest::Test
  def test_it_offers_a_tool_for_each_operation
    assert_equal %w[
      ask_anychat_list_agents
      ask_anychat_get_agent
      ask_anychat_create_agent
      ask_anychat_update_agent
      ask_anychat_delete_agent
      ask_anychat_list_sources
      ask_anychat_get_source
      ask_anychat_browse_pages
      ask_anychat_read_page
      ask_anychat_search_pages
    ], Ask::AnyChat::MCP.tools.map(&:name)
  end

  # The prefix keeps them from colliding with a client's own tools of the same
  # name — the same convention the other ask MCP servers follow.
  def test_every_tool_name_is_prefixed
    Ask::AnyChat::MCP.tools.each do |tool|
      assert tool.name.start_with?("ask_anychat_"), "#{tool.name} is not prefixed"
    end
  end

  def test_names_are_unique
    names = Ask::AnyChat::MCP.tools.map(&:name)

    assert_equal names.length, names.uniq.length
  end

  # The duck type the MCP adapter asks for.
  def test_every_tool_keeps_the_duck_type
    Ask::AnyChat::MCP.tools.each do |tool|
      %i[name description params_schema call].each do |message|
        assert_respond_to tool, message, "#{tool.name} does not answer to #{message}"
      end
    end
  end

  def test_every_tool_says_what_it_is_for
    Ask::AnyChat::MCP.tools.each do |tool|
      refute_empty tool.description.to_s.strip, "#{tool.name} has no description"
    end
  end

  # Every operation is scoped to a workspace, so every schema has to ask for
  # one — a tool that forgot would reach whichever workspace the token defaults
  # to, which is not a thing a model can be expected to know.
  def test_every_tool_requires_a_workspace
    Ask::AnyChat::MCP.tools.each do |tool|
      schema = tool.params_schema

      assert_equal "object", schema[:type], "#{tool.name} declares no object schema"
      assert_includes schema[:properties].keys.map(&:to_s), "workspace"
      assert_includes Array(schema[:required]), "workspace"
    end
  end

  # How the tests hold the API still, and how a host supplies its own client.
  def test_the_client_can_be_given_rather_than_resolved
    tools = Ask::AnyChat::MCP.tools(client: FakeClient.new)
    list = tools.find { |tool| tool.name == "ask_anychat_list_agents" }

    assert_equal "This workspace has no agents yet.", list.call({ "workspace" => "anywaye" })
  end
end
