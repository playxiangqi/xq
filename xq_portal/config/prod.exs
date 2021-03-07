use Mix.Config

config :xq,
  archive_service: "https://archive.playxiangqi.xyz/api"

config :xq, XQWeb.Endpoint,
  url: [host: "www.playxiangqi.xyz", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info
