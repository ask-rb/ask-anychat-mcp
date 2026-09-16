# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # The agents a workspace owns, oldest first.
        class ListAgents < Tool
          tool_name "ask_anychat_list_agents"
          description "List the agents a workspace owns, oldest first, with the address each " \
                      "answers on. Read this before creating or changing one — it is how you " \
                      "learn which addresses are already taken."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username, the first half of /<workspace>/<agent>"
              }
            },
            required: ["workspace"]
          )

          private

          def run(args)
            agents = anychat.workspace_agents(args["workspace"])
            return "This workspace has no agents yet." if agents.empty?

            agents.map { |agent| line(args["workspace"], agent) }.join("\n")
          end

          def line(workspace, agent)
            parts = ["#{agent['display_name']} at /#{workspace}/#{agent['handle']}"]
            parts << "— #{agent['description']}" if agent["description"].to_s.strip.length.positive?
            parts << "(private)" unless agent["public"]
            parts.join(" ")
          end
        end
      end
    end
  end
end
