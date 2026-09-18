# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # What an agent reads: the sources it was granted.
        class ListSources < Tool
          tool_name "ask_anychat_list_sources"
          description "List the sources an agent may read — the websites the workspace " \
                      "connected or the corpora it holds. Use this before browsing or " \
                      "reading pages, and before changing what an agent answers from."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username, the first half of /<workspace>/<agent>"
              },
              agent: {
                type: "string",
                description: "The agent's handle, the second half of /<workspace>/<agent>"
              }
            },
            required: %w[workspace agent]
          )

          private

          def run(args)
            sources = anychat.agent_sources(args["workspace"], args["agent"])
            return "This agent has no sources yet." if sources.empty?

            sources.map { |source| line(args["workspace"], args["agent"], source) }.join("\n")
          end

          def line(workspace, agent, source)
            parts = ["#{source['name']} at /#{workspace}/#{agent}/#{source['handle']}"]
            parts << "(#{source['kind']})" if source["kind"]
            if source["excluded_paths"]&.any?
              parts << "— set aside: #{source['excluded_paths'].join(', ')}"
            end
            parts.join(" ")
          end
        end
      end
    end
  end
end
