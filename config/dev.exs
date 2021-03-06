import Config

config :naive_dice, Reservation.Repo,
  username: "postgres",
  password: "postgres",
  database: "naive_dice_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

test_mode_api_key =
  "rk_test_51K1uECHcMxX2dWx5T4bhfUnxaPoTZ1Vv7vAbSsm0SYNv1uUvSWyAJgbd0uL8EWrqjCSXVYArr5NyH5as15iYaFu200g1aRELyk"

config :naive_dice, Stripe, api_key: test_mode_api_key

config :naive_dice, NaiveDiceWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch",
      "--watch-options-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :naive_dice, NaiveDiceWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/naive_dice_web/{live,views}/.*(ex)$",
      ~r"lib/naive_dice_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
