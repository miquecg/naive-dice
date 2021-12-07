import Config

if System.get_env("RELEASE_MODE") do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :naive_dice, Reservation.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  live_mode_api_key =
    System.get_env("STRIPE_API_KEY") ||
      raise """
      environment variable STRIPE_API_KEY is missing.
      """

  config :naive_dice, Stripe, api_key: live_mode_api_key

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :naive_dice, NaiveDiceWeb.Endpoint,
    http: [port: System.fetch_env!("PORT")],
    url: [
      scheme: "https",
      host: System.fetch_env!("APP_NAME") <> ".gigalixirapp.com",
      port: 443
    ],
    secret_key_base: secret_key_base
end
