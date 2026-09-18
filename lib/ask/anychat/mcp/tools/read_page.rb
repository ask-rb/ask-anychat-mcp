# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # One page of an agent's source, as clean markdown.
        class ReadPage < Tool
          tool_name "ask_anychat_read_page"
          description "Read one page an agent may read, by its reference, as clean " \
                      "markdown — from the content plane, or from the website itself " \
                      "when the plane has nothing stored."
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
              reference: {
                type: "string",
                description: "The page path, e.g. /pricing or /docs/cli"
              }
            },
            required: %w[workspace agent source reference]
          )

          private

          def run(args)
            page = anychat.agent_source_page(
              args["workspace"], args["agent"], args["source"], args["reference"]
            )

            "#{page['title']}\n\n#{page['content']}"
          end
        end
      end
    end
  end
end
