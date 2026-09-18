# frozen_string_literal: true

# A stand-in for Ask::AnyChat::Client: the same operations, answering from
# memory, and recording what it was asked to do. The tools are what these tests
# are about, not the HTTP underneath them.
class FakeClient
  attr_reader :created, :updated, :destroyed

  def initialize(agents: [], sources: {}, pages: {}, search_results: {})
    @agents = agents
    @sources = sources
    @pages = pages
    @search_results = search_results
    @created = []
    @updated = []
    @destroyed = []
  end

  # -- agents --------------------------------------------------------------

  def workspace_agents(workspace)
    @agents.map { |agent| addressed(workspace, agent) }
  end

  def workspace_agent(workspace, handle)
    agent = @agents.find { |candidate| candidate["handle"] == handle }
    raise Ask::AnyChat::Error::NotFound, "No agent at /#{workspace}/#{handle}." unless agent

    addressed(workspace, agent)
  end

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

  # -- sources -------------------------------------------------------------

  def agent_sources(workspace, agent)
    key = [workspace, agent]
    @sources.fetch(key) { raise Ask::AnyChat::Error::NotFound, "No agent at /#{workspace}/#{agent}." }
  end

  def agent_source(workspace, agent, handle)
    sources = agent_sources(workspace, agent)
    source = sources.find { |s| s["handle"] == handle }
    raise Ask::AnyChat::Error::NotFound, "No source #{handle} for this agent." unless source

    source
  end

  def agent_source_pages(workspace, agent, source_handle)
    key = [workspace, agent, source_handle]
    @pages.fetch(key) { raise Ask::AnyChat::Error::NotFound, "No source #{source_handle} for this agent." }
  end

  def agent_source_page(workspace, agent, source_handle, reference)
    key = [workspace, agent, source_handle, reference]
    @pages.fetch(key) { raise Ask::AnyChat::Error::NotFound, "No page at #{reference}." }
  end

  def agent_source_search(workspace, agent, source_handle, query)
    key = [workspace, agent, source_handle]
    @search_results.fetch(key) { raise Ask::AnyChat::Error::NotFound, "No source #{source_handle} for this agent." }
  end
end
