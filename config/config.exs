# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if File.exists?(Path.expand("config/secrets.exs")) do
  import_config "secrets.exs"
end
