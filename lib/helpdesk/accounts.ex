defmodule Helpdesk.Accounts do
  use Ash.Api

  resources do
    registry Helpdesk.Accounts.Registry
  end
end
