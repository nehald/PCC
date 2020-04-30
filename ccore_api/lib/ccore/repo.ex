defmodule CCore.Repo do
  use Ecto.Repo,
    otp_app: :ccore,
    adapter: Ecto.Adapters.Postgres
end
