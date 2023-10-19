defmodule HelpdeskWeb.TicketsLive do
  alias Helpdesk.Support.Ticket
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  import PetalComponents.{Button, Field, Typography}

  def render(assigns) do
    ~H"""
    <.async_result :let={tickets} assign={@tickets}>
      <:loading>Loading tickets...</:loading>
      <:failed :let={_reason}>there was an error loading the tickets</:failed>
      <div :for={ticket <- tickets}>
        <h1>Id: <%= ticket.id %></h1>
        <h1>Status: <%= ticket.status %></h1>
        <h1>Subject: <%= ticket.subject %></h1>
        <h1>User Id:<%= ticket.user_id %></h1>
        <.h1>
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
            Esto es especial o algo asi
          </span>
        </.h1>
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
    <.form for={@form} phx-submit="open_todo">
      <.field type="text" field={@form[:subject]} label="Subject" />
      <.button>Save</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(form: AshPhoenix.Form.for_create(Ticket, :open) |> to_form)
     |> assign_async(:tickets, fn -> get_tickets() end)}
  end

  defp get_tickets() do
    case Ticket.read() do
      {:ok, tickets} -> {:ok, %{tickets: tickets}}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_event("open_todo", %{"form" => %{"subject" => subject}}, socket) do
    Ticket.open(subject)

    {:noreply,
     socket
     |> assign_async(:tickets, fn -> get_tickets() end)}
  end

  def handle_event("delete_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.destroy!()

    {:noreply,
     socket
     |> assign_async(:tickets, fn -> get_tickets() end)}
  end

  def handle_event("close_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.close()

    {:noreply,
     socket
     |> assign_async(:tickets, fn -> get_tickets() end)}
  end

  def handle_event("reopen_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.reopen()
    # {:noreply, assign(socket, :tickets, Ticket.read!())}
    {:noreply,
     socket
     |> assign_async(:tickets, fn -> get_tickets() end)}
  end
end
