defmodule WebSocket do
  use ThousandIsland.Handler
  alias WebSocket.Handshake

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    if is_http_request?(data) do
      Handshake.handshake(data, socket)
      {:continue, state}
    else
    end
  end

  def is_http_request?(data) do
    [first_line | _] = String.split(data, "\r\n", trim: true)
    String.contains?(first_line, "HTTP")
  end
end
