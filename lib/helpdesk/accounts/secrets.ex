defmodule Helpdesk.Accounts.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], HelpdeskWeb.Accounts.User, _) do
    case Application.fetch_env(:helpdesk, HelpdeskWeb.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
