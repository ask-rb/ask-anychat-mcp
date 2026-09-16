# frozen_string_literal: true

require_relative "tools/list_agents"
require_relative "tools/get_agent"
require_relative "tools/create_agent"
require_relative "tools/update_agent"
require_relative "tools/delete_agent"

module Ask
  module AnyChat
    module MCP
      # Every tool this server exposes, in the order a model should reach for
      # them: read, then write, then retire.
      module Tools
        ALL = [
          ListAgents,
          GetAgent,
          CreateAgent,
          UpdateAgent,
          DeleteAgent
        ].freeze
      end
    end
  end
end
