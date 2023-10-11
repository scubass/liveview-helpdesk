defmodule Helpdesk.Accounts.Registry do
  use Ash.Registry

  entries do
    entry Helpdesk.Accounts.Token
    entry Helpdesk.Accounts.User
  end
end
