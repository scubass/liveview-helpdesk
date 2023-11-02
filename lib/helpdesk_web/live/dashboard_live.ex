defmodule HelpdeskWeb.DashboardLive do
  use Phoenix.LiveView
  alias Helpdesk.Support.Ticket
  use PetalComponents

  def render(assigns) do
    ~H"""
    <h1>Dashboard</h1>
    <.form for={@create_ticket} phx-submit="create_ticket" phx-change="validate_create_ticket">
      <.field type="text" field={@create_ticket[:subject]} label="subject" />
      <.field type="hidden" field={@create_ticket[:user_id]} value={@current_user.id} />
    </.form>
    <.async_result :let={tickets} assign={@tickets}>
      <:loading>Loading tickets...</:loading>
      <:failed :let={_reason}>there was an error loading the tickets</:failed>
      <div :for={ticket <- tickets}>
        <h1>Id: <%= ticket.id %></h1>
        <h1>Status: <%= ticket.status %></h1>
        <h1>Subject: <%= ticket.subject %></h1>
        <h1>User Id:<%= ticket.user_id %></h1>
        <.button phx-value-ticket-id={ticket.id} phx-click="delete_todo">Delete</.button>
        <.button
          class={"#{if ticket.status == :open do "text-red-600" else "text-green-600" end}"}
          phx-value-ticket-id={ticket.id}
          phx-click={"#{ if ticket.status == :open do "close_todo" else "reopen_todo" end}"}
        >
          <%= if ticket.status == :open do %>
            Close
          <% else %>
            Open
          <% end %>
        </.button>
      </div>
    </.async_result>
    """
  end

  def mount(_params, _session, socket) do
    user =
      socket.assigns.current_user
      |> Helpdesk.Support.load([:tickets])

    dbg(user)

    # TODO: Hash the hidden inputs
    {:ok,
     socket
     |> assign(create_ticket: AshPhoenix.Form.for_create(Ticket, :open_and_assign) |> to_form())
     |> get_tickets()}
  end

  defp get_tickets(socket) do
    socket
    |> assign_async(:tickets, fn ->
      case Helpdesk.Support.load(socket.assigns.current_user, [:tickets]) do
        {:ok, user} -> {:ok, %{tickets: user.tickets}}
        {:error, reason} -> {:error, reason}
      end
    end)
  end

  def handle_event(
        "create_ticket",
        %{"form" => %{"subject" => subject, "user_id" => user_id}},
        socket
      ) do
    Helpdesk.Support.Ticket.open_and_assign!(subject, user_id)
    {:noreply, socket |> get_tickets}
  end

  def handle_event(
        "validate_create_ticket",
        %{"form" => params},
        socket
      ) do
    form =
      AshPhoenix.Form.validate(socket.assigns.create_ticket, params)
      |> to_form()

    {:noreply, assign(socket, create_ticket: form)}
  end
end
