defmodule HelpdeskWeb.ImagesLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <h1>Hello</h1>
    <image :for={i <- 1..7} src={"images/nasa-#{i}.jpg"} />
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
