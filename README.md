# Ask::AnyChat::MCP

MCP server for [Anychat](https://anywaye.com), for the
[ask-rb](https://github.com/ask-rb) ecosystem.

Exposes the agents a workspace owns as callable tools over stdio, so a client
that speaks the Model Context Protocol can create and manage them without
knowing anything about the API underneath. The tool shell lives here; the API
client is [ask-anychat](https://github.com/ask-rb/ask-anychat).

## Installation

```ruby
gem "ask-anychat-mcp"
```

## Usage

Register the executable with an MCP client:

```json
{
  "mcp": {
    "servers": {
      "ask-anychat-mcp": {
        "type": "stdio",
        "command": "ask-anychat-mcp",
        "env": { "ANYCHAT_TOKEN": "..." }
      }
    }
  }
}
```

Set `ANYCHAT_BASE_URL` too when pointing at a deployment that is not the hosted
app. Mint a token in Anychat under Settings → API tokens.

### Tools

| Tool | What it does |
| --- | --- |
| `ask_anychat_list_agents` | Every agent a workspace owns, with the address each answers on |
| `ask_anychat_get_agent` | One agent, by the address it answers on |
| `ask_anychat_create_agent` | Bring a new agent into being — a name is all it takes |
| `ask_anychat_update_agent` | Change one; only the arguments you pass are written |
| `ask_anychat_delete_agent` | Retire one; its address becomes free |

Every tool names a workspace, because a workspace is what a token reaches.

Names are prefixed `ask_anychat_` to keep them from colliding with a client's own
tools of the same name, as the other ask MCP servers are.

### What comes back

A refusal is text the model can act on rather than an exception that ends the
conversation, and it carries the sentence the API wrote:

```
Error: No agent at /anywaye/nope.
```

The same is true of an argument that was missing or misspelled — a model that
typed `name` where `display_name` was wanted is told so, rather than having the
value quietly dropped.

## Contributing

Run `bin/setup` once, then `bundle exec rake test`. Until `ask-anychat` and
`ask-mcp` are released, the Gemfile consumes both from the working copies
alongside this one.

## License

MIT.
