defmodule HelpdeskWeb.HelloLive do
  use Phoenix.LiveView
  import PetalComponents.Button

  def render(assigns) do
    ~H"""
    <h1>Hello World</h1>
    <.button color="success" label="Success" variant="outline" />
    <.button color="info" label="Info" />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
