defmodule Harjoitustehtava.Repo do
  use Ecto.Repo,
    otp_app: :harjoitustehtava,
    adapter: Ecto.Adapters.SQLite3
end
