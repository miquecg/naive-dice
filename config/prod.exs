import Config

config :naive_dice, NaiveDiceWeb.Endpoint,
  server: true,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info
