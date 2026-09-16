# frozen_string_literal: true

module Ask
  module AnyChat
    module MCP
      # The duck type the MCP adapter expects: a name, a description, a JSON
      # Schema, and a call.
      #
      # Arguments are checked here rather than at the API, so a model that
      # misspells a parameter is told which one it typed and which were on
      # offer — instead of being handed a status code it cannot read. Failures
      # come back as text for the same reason: this is a conversation.
      class Tool
        class << self
          # Not `name`: that is already how a class answers to itself, and
          # taking it over breaks more than it tells.
          def tool_name(value = nil)
            @tool_name = value if value
            @tool_name
          end

          def description(text = nil)
            @description = text if text
            @description
          end

          def params(schema = nil)
            @params = schema if schema
            @params || {}
          end
        end

        def initialize(client: nil)
          @client = client
        end

        def name
          self.class.tool_name
        end

        def description
          self.class.description
        end

        def params_schema
          self.class.params
        end

        def call(arguments = {})
          args = stringify(arguments)
          violation = violation(args)
          return violation if violation

          run(args)
        rescue AnyChat::Error => e
          "Error: #{e.message}"
        end

        private

        attr_reader :client

        # Built once per call and only if a tool needs it, so the server can be
        # started without a token in the environment.
        def anychat
          @anychat ||= client || AnyChat.client
        end

        def run(_args)
          raise NotImplementedError, "#{self.class} must implement #run"
        end

        def stringify(arguments)
          arguments.each_with_object({}) { |(key, value), out| out[key.to_s] = value }
        end

        # Unknown and missing arguments are named, not ignored: a model that
        # typed `name` where `display_name` was wanted should hear about it.
        def violation(args)
          allowed = params_schema[:properties].to_h.keys.map(&:to_s)
          required = Array(params_schema[:required]).map(&:to_s)

          missing = required - args.keys
          if missing.any?
            return "Error: missing required argument(s): #{missing.join(', ')}. Expected: #{allowed.join(', ')}"
          end

          extra = args.keys - allowed
          return "Error: unknown argument(s): #{extra.join(', ')}. Expected: #{allowed.join(', ')}" if extra.any?

          nil
        end

        # Only what the caller actually sent: an omitted optional argument is an
        # omission, not a nil to write over what is already there.
        def writable(args, *names)
          names.each_with_object({}) do |name, out|
            key = name.to_s
            out[name.to_sym] = args[key] if args.key?(key)
          end
        end
      end
    end
  end
end
