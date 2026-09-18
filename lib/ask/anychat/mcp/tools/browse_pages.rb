# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # Every page an agent may read, across its sources.
        class BrowsePages < Tool
          tool_name "ask_anychat_browse_pages"
          description "List every page an agent may read in a source — the manifest — " \
                      "with set-aside pages already left out. Use this to find a page, " \
                      "then read it by reference."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username"
              },
              agent: {
                type: "string",
                description: "The agent's handle"
              },
              source: {
                type: "string",
                description: "The source's handle, as list_sources reports it"
              }
            },
            required: %w[workspace agent source]
          )

          private

          def run(args)
            pages = anychat.agent_source_pages(args["workspace"], args["agent"], args["source"])
            return "This source has no pages yet." if pages.empty?

            "#{pages.length} pages:\n#{pages.map { |p| "#{p['reference']} — #{p['title']}" }.join("\n")}"
          end
        end
      end
    end
  end
end
