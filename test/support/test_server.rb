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
end

Ask::AnyChat::MCP.start(client: StubClient.new)
