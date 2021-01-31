# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :xq,
  namespace: XQ,
  ecto_repos: [XQ.Repo]

# Configures the endpoint
config :xq, XQWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LipoQCJjWGtBPaLpn9aDNSA7x/dXGylGpEMGr3srcTYNvxa8FKvwUxJiBNnSt+qm",
  render_errors: [view: XQWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: XQ.PubSub,
  live_view: [signing_salt: "VuWCDEDn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
