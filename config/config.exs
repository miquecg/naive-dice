use Mix.Config

config :naive_dice,
  ecto_repos: [NaiveDice.Repo]

config :naive_dice, NaiveDiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JvdAK76n53ApcZVDT3awEijcXOUVcwAxDG5Qza3KduNqVbGZhV2rb8PT9u4mq4zw",
  render_errors: [view: NaiveDiceWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: NaiveDice.PubSub

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
