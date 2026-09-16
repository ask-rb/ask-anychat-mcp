# frozen_string_literal: true

require_relative "test_helper"

# The server, driven end-to-end by a real MCP client over a real stdio
# subprocess. The tool tests prove what each tool does; this proves the protocol
# around them — that they are listed, that they are callable by name, and that
# the revision the two sides agree on is the current one.
class ServerTest < Minitest::Test
  def setup
    @script = File.expand_path("support/test_server.rb", __dir__)
  end

  def teardown
    @client&.stop
  rescue StandardError
    nil
  end

  def spawn_client
    transport = Ask::MCP::Transport::Stdio.new(
      "ruby", [@script],
      env: { "BUNDLE_GEMFILE" => File.expand_path("../Gemfile", __dir__) }
    )
    @client = Ask::MCP::Client.new(transport, timeout: 10)
    @client.start
  end

  def text_of(content)
    content.is_a?(Array) ? content.first[:text] : content.dig(:content, 0, :text)
  end

  def test_negotiates_the_stateless_protocol
    spawn_client

    assert_predicate @client, :initialized?
    assert_equal Ask::MCP::LATEST_PROTOCOL_VERSION,
                 @client.instance_variable_get(:@protocol_version)
  end

  def test_lists_every_tool
    spawn_client

    assert_equal %w[
      ask_anychat_list_agents
      ask_anychat_get_agent
      ask_anychat_create_agent
      ask_anychat_update_agent
      ask_anychat_delete_agent
    ].sort, @client.tools.keys.sort
  end

  def test_calls_a_tool_by_name
    spawn_client

    text = text_of(@client.call_tool("ask_anychat_list_agents", { workspace: "anywaye" }))

    assert_includes text, "Support at /anywaye/support"
  end

  def test_a_refusal_travels_back_as_text
    spawn_client

    text = text_of(@client.call_tool("ask_anychat_get_agent", { workspace: "anywaye", agent: "nope" }))

    assert_includes text, "Error:"
    assert_includes text, "No agent at /anywaye/nope."
  end

  # The schema the tool declared is enforced at the protocol boundary before the
  # tool is reached at all, which is the right place for it to happen.
  def test_a_bad_argument_is_reported_rather_than_raised
    spawn_client

    text = text_of(@client.call_tool("ask_anychat_create_agent", { workspace: "anywaye" }))

    assert_includes text, "Missing required parameter(s)"
    assert_includes text, "display_name"
  end

  def test_an_unknown_tool_is_reported
    spawn_client

    text = text_of(@client.call_tool("ask_anychat_nonexistent", {}))

    assert_includes text, "Tool not found"
  end
end
