# frozen_string_literal: true

require_relative "tools/list_agents"
require_relative "tools/get_agent"
require_relative "tools/create_agent"
require_relative "tools/update_agent"
require_relative "tools/delete_agent"
require_relative "tools/list_sources"
require_relative "tools/get_source"
require_relative "tools/browse_pages"
require_relative "tools/read_page"
require_relative "tools/search_pages"

module Ask
  module AnyChat
    module MCP
      # Every tool this server exposes, in the order a model should reach for
      # them: agents first, then sources, then pages.
      module Tools
        ALL = [
          ListAgents,
          GetAgent,
          CreateAgent,
          UpdateAgent,
          DeleteAgent,
          ListSources,
          GetSource,
          BrowsePages,
          ReadPage,
          SearchPages
        ].freeze
      end
    end
  end
end
