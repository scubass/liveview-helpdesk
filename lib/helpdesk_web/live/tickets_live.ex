defmodule HelpdeskWeb.TicketsLive do
  alias Helpdesk.Support.Ticket
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  import HelpdeskWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div :for={ticket <- @tickets}>
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
    <.form for={@form} phx-submit="open_todo">
      <.input type="text" field={@form[:subject]} label="Subject" />
      <.button>Save</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       :tickets,
       Ticket.read!()
     )
     |> assign(form: AshPhoenix.Form.for_create(Ticket, :open) |> to_form)}
  end

  def handle_event("open_todo", %{"form" => %{"subject" => subject}}, socket) do
    Ticket.open(subject)
    {:noreply, assign(socket, :tickets, Ticket.read!())}
  end

  def handle_event("delete_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.destroy!()
    {:noreply, assign(socket, :tickets, Ticket.read!())}
  end

  def handle_event("close_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.close()
    {:noreply, assign(socket, :tickets, Ticket.read!())}
  end

  def handle_event("reopen_todo", %{"ticket-id" => post_id}, socket) do
    post_id |> Ticket.get_by_id!() |> Ticket.reopen()
    {:noreply, assign(socket, :tickets, Ticket.read!())}
  end
end
