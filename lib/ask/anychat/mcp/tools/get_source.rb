# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # One source of an agent's, and what was carved out of its grant.
        class GetSource < Tool
          tool_name "ask_anychat_get_source"
          description "Show one source an agent reads, by the handle list_sources returns. " \
                      "Includes which pages were set aside."
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
            source = anychat.agent_source(args["workspace"], args["agent"], args["source"])

            lines = [
              "#{source['name']} (#{source['kind']}) at #{source['address']}"
            ]
            if source["excluded_paths"]&.any?
              lines << "Set aside: #{source['excluded_paths'].join(', ')}"
            else
              lines << "All pages available."
            end
            lines.join("\n")
          end
        end
      end
    end
  end
end
