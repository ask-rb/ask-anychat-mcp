## [0.1.2] - 2026-09-17

### Changed

- Require ask-anychat `>= 0.1.0` — the client this server is built on is
  released now, so the dependency is on the release rather than on a checkout.

## [0.1.1] - 2026-09-17

### Changed

- Require ask-mcp `>= 0.5.0`, the release that serves MCP over the stateless
  Streamable HTTP transport.

## [0.1.0] - 2026-09-17

### Added

- **An MCP server for Anychat**, served over stdio —
  `Ask::AnyChat::MCP.start` and the `ask-anychat-mcp` executable. Tool names are
  prefixed `ask_anychat_` so they cannot collide with a client's own tools of the
  same name, as the other ask MCP servers are.

- **Five tools, one per operation** — `ask_anychat_list_agents`,
  `ask_anychat_get_agent`, `ask_anychat_create_agent`,
  `ask_anychat_update_agent` and `ask_anychat_delete_agent`. Every one names a
  workspace, because a workspace is what a token reaches.

- **Arguments checked before the call** — a missing or misspelled argument is
  named, with the ones that were on offer, rather than being dropped and
  surfacing later as an unexplained result. The schema each tool declares is
  also enforced at the protocol boundary.

- **Refusals come back as text** — the sentence the API wrote, prefixed with
  `Error:`, so a model can act on it instead of being handed an exception that
  ends the conversation.

- **`Ask::AnyChat::MCP.tools(client:)`** — the client can be supplied, which is
  how a host points the server at a particular deployment and how the tests hold
  the API still.
