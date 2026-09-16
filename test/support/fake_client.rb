# frozen_string_literal: true

# A stand-in for Ask::AnyChat::Client: the same operations, answering from
# memory, and recording what it was asked to do. The tools are what these tests
# are about, not the HTTP underneath them.
class FakeClient
  attr_reader :created, :updated, :destroyed

  def initialize(agents: [])
    @agents = agents
    @created = []
    @updated = []
    @destroyed = []
  end

  def workspace_agents(workspace)
    @agents.map { |agent| addressed(workspace, agent) }
  end

  def workspace_agent(workspace, handle)
    agent = @agents.find { |candidate| candidate["handle"] == handle }
    raise Ask::AnyChat::Error::NotFound, "No agent at /#{workspace}/#{handle}." unless agent

    addressed(workspace, agent)
  end

  # The API always answers with the address an agent answers on, so the stand-in
  # does too — a tool that read it would otherwise be tested against nothing.
  def addressed(workspace, agent)
    agent.merge("address" => "/#{workspace}/#{agent['handle']}")
  end

  def create_workspace_agent(workspace, **attributes)
    @created << attributes
    handle = attributes[:handle] || attributes[:display_name].to_s.downcase
    {
      "handle" => handle,
      "display_name" => attributes[:display_name],
      "address" => "/#{workspace}/#{handle}"
    }
  end

  def update_workspace_agent(workspace, handle, **attributes)
    @updated << [handle, attributes]
    moved = attributes[:handle] || handle
    {
      "handle" => moved,
      "display_name" => attributes[:display_name] || "Support",
      "address" => "/#{workspace}/#{moved}"
    }
  end

  def destroy_workspace_agent(workspace, handle)
    @destroyed << [workspace, handle]
    {}
  end
end
