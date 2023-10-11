defmodule Helpdesk.Repo do
  use AshPostgres.Repo, otp_app: :helpdesk

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
