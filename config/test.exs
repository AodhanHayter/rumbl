use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rumbl, Rumbl.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rumbl, Rumbl.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "Aodhan",
  password: "ah1168136",
  database: "rumbl_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Ease password hashing when running tests for speed
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1