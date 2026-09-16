# frozen_string_literal: true

require_relative "../test_helper"

# What each tool does with what it is given, and what it says back. A model
# reads these answers, so they are written to be read.
class AgentToolsTest < Minitest::Test
  AGENTS = [
    { "handle" => "support", "display_name" => "Support", "description" => "Answers questions", "public" => true },
    { "handle" => "sales", "display_name" => "Sales", "description" => nil, "public" => false }
  ].freeze

  def tool(klass, client: FakeClient.new(agents: AGENTS.dup))
    klass.new(client: client)
  end

  # -- list ---------------------------------------------------------------

  def test_list_names_each_agent_by_its_address
    answer = tool(Ask::AnyChat::MCP::Tools::ListAgents).call({ "workspace" => "anywaye" })

    assert_includes answer, "Support at /anywaye/support"
    assert_includes answer, "Sales at /anywaye/sales"
  end

  def test_list_says_when_an_agent_is_private
    answer = tool(Ask::AnyChat::MCP::Tools::ListAgents).call({ "workspace" => "anywaye" })

    assert_includes answer, "Sales at /anywaye/sales (private)"
  end

  def test_list_says_so_when_there_are_none
    answer = tool(Ask::AnyChat::MCP::Tools::ListAgents, client: FakeClient.new).call({ "workspace" => "anywaye" })

    assert_equal "This workspace has no agents yet.", answer
  end

  # -- get ----------------------------------------------------------------

  def test_get_reads_one_agent
    answer = tool(Ask::AnyChat::MCP::Tools::GetAgent).call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "/anywaye/support"
    assert_includes answer, "Answers questions"
  end

  def test_get_says_how_visible_it_is
    answer = tool(Ask::AnyChat::MCP::Tools::GetAgent).call({ "workspace" => "anywaye", "agent" => "sales" })

    assert_includes answer, "Private"
  end

  # -- create -------------------------------------------------------------

  def test_create_passes_only_what_it_was_given
    client = FakeClient.new
    tool(Ask::AnyChat::MCP::Tools::CreateAgent, client: client)
      .call({ "workspace" => "anywaye", "display_name" => "Support" })

    assert_equal [{ display_name: "Support" }], client.created
  end

  def test_create_passes_the_optional_ones_when_asked
    client = FakeClient.new
    tool(Ask::AnyChat::MCP::Tools::CreateAgent, client: client).call(
      { "workspace" => "anywaye", "display_name" => "Support", "handle" => "help", "public" => false }
    )

    assert_equal [{ display_name: "Support", handle: "help", public: false }], client.created
  end

  def test_create_names_the_address_it_landed_on
    answer = tool(Ask::AnyChat::MCP::Tools::CreateAgent)
             .call({ "workspace" => "anywaye", "display_name" => "Support" })

    assert_equal "Created Support at /anywaye/support.", answer
  end

  # -- update -------------------------------------------------------------

  def test_update_sends_only_the_attributes_it_was_given
    client = FakeClient.new
    tool(Ask::AnyChat::MCP::Tools::UpdateAgent, client: client).call(
      { "workspace" => "anywaye", "agent" => "support", "display_name" => "Help desk" }
    )

    assert_equal [["support", { display_name: "Help desk" }]], client.updated
  end

  # `agent` is which one, `handle` is what to move it to. One name for both
  # would be a request that cannot be read.
  def test_update_moves_the_address_when_asked
    client = FakeClient.new
    tool(Ask::AnyChat::MCP::Tools::UpdateAgent, client: client).call(
      { "workspace" => "anywaye", "agent" => "support", "handle" => "help" }
    )

    assert_equal [["support", { handle: "help" }]], client.updated
  end

  def test_update_refuses_a_request_that_changes_nothing
    client = FakeClient.new
    answer = tool(Ask::AnyChat::MCP::Tools::UpdateAgent, client: client)
             .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "nothing to change"
    assert_empty client.updated
  end

  # -- delete -------------------------------------------------------------

  def test_delete_names_the_address_it_freed
    answer = tool(Ask::AnyChat::MCP::Tools::DeleteAgent).call({ "workspace" => "anywaye", "agent" => "support" })

    assert_includes answer, "/anywaye/support"
    assert_includes answer, "free again"
  end

  def test_delete_asks_the_api_to_destroy_it
    client = FakeClient.new
    tool(Ask::AnyChat::MCP::Tools::DeleteAgent, client: client)
      .call({ "workspace" => "anywaye", "agent" => "support" })

    assert_equal [%w[anywaye support]], client.destroyed
  end

  # -- what a refusal looks like ------------------------------------------

  # A failure is text the model can act on, not an exception that ends the
  # conversation — and it carries the sentence the API wrote.
  def test_a_refusal_comes_back_as_text
    answer = tool(Ask::AnyChat::MCP::Tools::GetAgent).call({ "workspace" => "anywaye", "agent" => "nope" })

    assert_includes answer, "Error:"
    assert_includes answer, "No agent at /anywaye/nope."
  end

  # -- what a bad argument looks like -------------------------------------

  def test_a_missing_argument_names_what_was_wanted
    answer = tool(Ask::AnyChat::MCP::Tools::CreateAgent).call({ "workspace" => "anywaye" })

    assert_includes answer, "missing required argument(s): display_name"
    assert_includes answer, "workspace"
  end

  # A model that typed `name` where `display_name` was wanted should hear about
  # it rather than have the value silently dropped.
  def test_an_unknown_argument_names_it
    answer = tool(Ask::AnyChat::MCP::Tools::CreateAgent)
             .call({ "workspace" => "anywaye", "display_name" => "Support", "name" => "Support" })

    assert_includes answer, "unknown argument(s): name"
  end
end
