#!/usr/bin/env ruby
# frozen_string_literal: true

# Spawned as a subprocess by the integration tests. The API client is a stand-in,
# so nothing here touches the network.

require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ask-anychat-mcp"

SUPPORT = {
  "handle" => "support",
  "display_name" => "Support",
  "description" => "Answers questions",
  "public" => true
}.freeze

class StubClient
  SOURCE = {
    "handle" => "website", "kind" => "site", "name" => "Example",
    "address" => "/anywaye/support/website", "excluded_paths" => []
  }.freeze

  def workspace_agents(_workspace)
    [SUPPORT]
  end

  def workspace_agent(workspace, handle)
    raise Ask::AnyChat::Error::NotFound, "No agent at /#{workspace}/#{handle}." unless handle == "support"

    SUPPORT.merge("address" => "/#{workspace}/support")
  end

  def create_workspace_agent(workspace, **attributes)
    handle = attributes[:handle] || attributes[:display_name].to_s.downcase
    { "handle" => handle, "display_name" => attributes[:display_name], "address" => "/#{workspace}/#{handle}" }
  end

  def update_workspace_agent(workspace, handle, **attributes)
    moved = attributes[:handle] || handle
    { "handle" => moved, "display_name" => attributes[:display_name] || "Support",
      "address" => "/#{workspace}/#{moved}" }
  end

  def destroy_workspace_agent(_workspace, _handle)
    {}
  end

  def agent_sources(_workspace, _agent)
    [SOURCE]
  end

  def agent_source(_workspace, _agent, handle)
    raise Ask::AnyChat::Error::NotFound, "No source #{handle}." unless handle == "website"

    SOURCE
  end

  def agent_source_pages(_workspace, _agent, _source)
    [{ "reference" => "/pricing", "title" => "Pricing" }]
  end

  def agent_source_page(_workspace, _agent, _source, reference)
    raise Ask::AnyChat::Error::NotFound, "No page at #{reference}." unless reference == "/pricing"

    { "title" => "Pricing", "content" => "# Pricing\n\n$9/mo.", "source" => "website" }
  end

  def agent_source_search(_workspace, _agent, _source, query)
    [{ "reference" => "/pricing", "title" => "Pricing", "snippet" => "Plans start at..." }]
  end
end

Ask::AnyChat::MCP.start(client: StubClient.new)
