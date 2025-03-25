defmodule WebSocket do
  use ThousandIsland.Handler
  alias WebSocket.Request

  @impl THousandIsland.Handler
  def handle_connection(socket, state) do
    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    IO.puts("Socket: #{inspect(socket)}")
    request = Request.parse(data)
    header = Request.to_string(request)
    IO.puts("Sending")

    ThousandIsland.Socket.send(
      socket,
      make_response_header(header) <> header
    )

    {:continue, state}
  end

  def make_response_header(body) do
    "HTTP/1.1 200 OK\r\n" <>
      "content-length:#{String.length(body)}\r\n" <>
      "content-type: text; charset=utf-8\r\n" <>
      "\r\n"
  end
end
