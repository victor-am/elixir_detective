use Mix.Config

config :logger, :console,
  format: "| $message\n",
  colors: [enabled: true],
  level: :error

import_config "#{Mix.env()}.exs"