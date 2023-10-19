defmodule Helpdesk.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  authentication do
    api Helpdesk.Accounts

    strategies do
      password :password do
        identity_field(:email)

        resettable do
          sender Helpdesk.Accounts.User.Senders.SendPasswordResetEmail
        end
      end
    end

    tokens do
      enabled?(true)
      token_resource(Helpdesk.Accounts.Token)

      signing_secret(fn _, _ ->
        Application.fetch_env(:helpdesk, :token_signing_secret)
      end)
    end
  end

  postgres do
    table "users"
    repo Helpdesk.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  relationships do
    has_many :tickets, Helpdesk.Support.Ticket do
      api Helpdesk.Support
    end
  end

  # If using policies, add the folowing bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
