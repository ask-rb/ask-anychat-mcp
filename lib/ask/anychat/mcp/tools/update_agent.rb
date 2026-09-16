# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # What an existing agent becomes.
        #
        # The address being changed and the address being changed *to* are two
        # different things, so they are two different arguments: `agent` says
        # which one, `handle` says what to move it to. One name for both would
        # be a sentence that cannot be read.
        class UpdateAgent < Tool
          tool_name "ask_anychat_update_agent"
          description "Change an agent a workspace already owns. Only the arguments you pass " \
                      "are written — anything left out keeps its value. Pass handle to move " \
                      "the address it answers on."
          params(
            type: "object",
            properties: {
              workspace: {
                type: "string",
                description: "The workspace's username, the first half of /<workspace>/<agent>"
              },
              agent: {
                type: "string",
                description: "The address it answers on now, the second half of /<workspace>/<agent>"
              },
              display_name: {
                type: "string",
                description: "What the agent is called."
              },
              handle: {
                type: "string",
                description: "The address to move it to. A taken one is given the first free variant."
              },
              description: {
                type: "string",
                description: "One line about what this agent is for."
              },
              public: {
                type: "boolean",
                description: "Whether the world can find it."
              }
            },
            required: %w[workspace agent]
          )

          private

          def run(args)
            attributes = writable(args, :display_name, :handle, :description, :public)
            return nothing_to_change if attributes.empty?

            agent = anychat.update_workspace_agent(args["workspace"], args["agent"], **attributes)

            "Updated #{agent['display_name']} at #{agent['address']}."
          end

          def nothing_to_change
            "Error: nothing to change. Pass at least one of display_name, handle, description, public."
          end
        end
      end
    end
  end
end
