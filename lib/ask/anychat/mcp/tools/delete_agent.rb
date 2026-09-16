# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      module Tools
        # An agent leaves the workspace, and its address becomes free.
        #
        # Conversations customers had with it are kept, so a retired agent still
        # appears in that history — which is worth saying, because an owner who
        # expects the record gone would be wrong to.
        class DeleteAgent < Tool
          tool_name "ask_anychat_delete_agent"
          description "Retire an agent from a workspace. Its address becomes free for another " \
                      "agent to take. Conversations it already had are kept."
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
            anychat.destroy_workspace_agent(args["workspace"], args["agent"])

            "Retired the agent at /#{args['workspace']}/#{args['agent']}. The address is free again."
          end
        end
      end
    end
  end
end
