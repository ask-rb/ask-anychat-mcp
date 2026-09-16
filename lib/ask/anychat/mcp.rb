# frozen_string_literal: true

require "ask/mcp"
require "ask-anychat"
require_relative "mcp/version"
require_relative "mcp/tool"
require_relative "mcp/tools"

module Ask
  module AnyChat
    # MCP (Model Context Protocol) server for Anychat.
    #
    # Exposes workspace agent CRUD over MCP, so a client that speaks the
    # protocol can create and manage a workspace's agents without knowing
    # anything about this API. Tool names are prefixed `ask_anychat_` to keep
    # them from colliding with a client's own tools of the same name.
    module MCP
      # Every tool, each holding the client it was given — or building one from
      # the environment on first use, which is what the executable relies on.
      def self.tools(client: nil)
        Tools::ALL.map { |tool| tool.new(client: client) }
      end

      # Serve over stdio. Blocking — the last line of an entry-point script.
      #
      #   $ ask-anychat-mcp
      #
      # Register it with an MCP client by command; set ANYCHAT_TOKEN and, if it
      # is not the hosted app, ANYCHAT_BASE_URL in the server's environment.
      def self.start(client: nil)
        Ask::MCP::Server.start_stdio(
          name: "ask-anychat-mcp",
          version: VERSION,
          tools: tools(client: client),
          capabilities: { tools: {} },
          debug: ENV["DEBUG"] == "1"
        )
      end
    end
  end
end
