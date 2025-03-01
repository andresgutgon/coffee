import Config

config :bun,
  version: "1.2.1",
  dev: [
    args: ~w(x --bun vite),
    cd: Path.expand("../assets", __DIR__),
    env: %{}
  ],
  install: [
    args: ~w(i),
    cd: Path.expand("../assets", __DIR__),
    env: %{}
  ],
  build: [
    args: ~w(x --bun vite build),
    cd: Path.expand("../assets", __DIR__),
    env: %{}
  ],
  css: [
    args: ~w(run tailwindcss --input=css/app.css --output=../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__),
    env: %{}
  ]

config :app,
  ecto_repos: [App.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AppWeb.ErrorHTML, json: AppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: App.PubSub,
  live_view: [signing_salt: "zsXRpt9Y"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :app, App.Mailer, adapter: Swoosh.Adapters.Local

# config/config.exs

config :inertia,
  endpoint: AppWeb.Endpoint,
  static_paths: ["/assets/app.js"],
  default_version: "1",
  camelize_props: false,
  history: [encrypt: false],
  # Configured by route where we need/want SSR
  ssr: false,
  raise_on_ssr_failure: config_env() != :prod

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
