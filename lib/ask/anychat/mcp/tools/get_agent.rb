# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # One agent, by the address it answers on.
        class GetAgent < Tool
          tool_name "ask_anychat_get_agent"
          description "Read one agent of a workspace, by the address it answers on. Use " \
                      "ask_anychat_list_agents first if you do not know the address."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username, the first half of /<workspace>/<agent>"
              },
              agent: {
                type: "string",
                description: "The address it answers on, the second half of /<workspace>/<agent>"
              }
            },
            required: %w[workspace agent]
          )

          private

          def run(args)
            agent = anychat.workspace_agent(args["workspace"], args["agent"])

            [
              "#{agent['display_name']} at #{agent['address']}",
              agent["description"].to_s.strip.empty? ? nil : agent["description"],
              agent["public"] ? "Public" : "Private"
            ].compact.join("\n")
          end
        end
      end
    end
  end
end
