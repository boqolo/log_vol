use Mix.Config

# Configures the logging volume
config :log_vol, :volume, :normal

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
