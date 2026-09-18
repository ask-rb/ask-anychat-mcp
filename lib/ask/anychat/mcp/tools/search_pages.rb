# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # Search what an agent reads, within the pages it may read.
        class SearchPages < Tool
          tool_name "ask_anychat_search_pages"
          description "Search the pages an agent may read in a source. Returns " \
                      "references, titles, and snippets — read one by reference " \
                      "for the whole page."
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
              },
              query: {
                type: "string",
                description: "What to look for"
              }
            },
            required: %w[workspace agent source query]
          )

          private

          def run(args)
            results = anychat.agent_source_search(
              args["workspace"], args["agent"], args["source"], args["query"]
            )
            return "Nothing found for #{args["query"]}." if results.empty?

            results.map { |r| "#{r['reference']} — #{r['title']}: #{r['snippet']}" }.join("\n")
          end
        end
      end
    end
  end
end
