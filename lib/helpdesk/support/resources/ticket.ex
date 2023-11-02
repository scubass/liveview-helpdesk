defmodule Helpdesk.Support.Ticket do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    table "tickets"
    repo Helpdesk.Repo
  end

  code_interface do
    define_for Helpdesk.Support
    define :open, args: [:subject]
    define :close, args: []
    define :reopen, args: []
    define :get_by_id, args: [:id], action: :by_id
    define :get_by_user_id, args: [:user_id], action: :by_user_id
    define :read
    define :update
    define :destroy
    define :open_and_assign, args: [:subject, :user_id]
  end

  actions do
    defaults [:read, :update, :destroy]

    create :open_and_assign do
      accept [:subject]

      argument :user_id, :uuid, allow_nil?: false

      change manage_relationship(:user_id, :user, type: :append_and_remove)
    end

    create :open do
      accept [:subject]
    end

    update :close do
      accept []
      change set_attribute(:status, :closed)
    end

    update :reopen do
      accept []
      change set_attribute(:status, :open)
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false

      get? true
      filter expr(id == ^arg(:id))
    end

    read :by_user_id do
      argument :user_id, :uuid, allow_nil?: false

      filter expr(user_id == ^arg(:user_id))
    end

    update :assign do
      accept []

      argument :user_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:user_id, :user, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :atom do
      constraints one_of: [:open, :closed]

      default :open
    end

    attribute :subject, :string do
      constraints min_length: 5,
                  allow_empty?: false
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Helpdesk.Accounts.User do
      api Helpdesk.Accounts
    end
  end
end
