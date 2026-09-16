# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # A new agent for a workspace.
        class CreateAgent < Tool
          tool_name "ask_anychat_create_agent"
          description "Bring a new agent into being in a workspace. Only a name is needed; " \
                      "the address it answers on is derived from that name, and a taken one " \
                      "is handed the first free variant rather than failing. Pass handle to " \
                      "choose the address yourself."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username, the first half of /<workspace>/<agent>"
              },
              display_name: {
                type: "string",
                description: "What the agent is called, e.g. \"Support\""
              },
              handle: {
                type: "string",
                description: "The address to answer on. Defaults to one derived from the name."
              },
              description: {
                type: "string",
                description: "One line about what this agent is for."
              },
              public: {
                type: "boolean",
                description: "Whether the world can find it. Defaults to true."
              }
            },
            required: %w[workspace display_name]
          )

          private

          def run(args)
            agent = anychat.create_workspace_agent(
              args["workspace"],
              **writable(args, :display_name, :handle, :description, :public)
            )

            "Created #{agent['display_name']} at #{agent['address']}."
          end
        end
      end
    end
  end
end
