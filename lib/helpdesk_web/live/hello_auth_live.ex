defmodule HelpdeskWeb.HelloAuthLive do
  alias Helpdesk.Accounts
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <h1>Hello</h1>
    <h2><%= @current_user.id %></h2>
    """
  end

  def mount(_params, _session, socket) do
    dbg(socket)

    current_user = socket.assigns.current_user |> Accounts.load!(:tickets)

    {:ok, assign(socket, :current_user, current_user)}
  end
end
