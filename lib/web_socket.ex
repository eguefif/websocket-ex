defmodule WebSocket do
  use ThousandIsland.Handler
  alias WebSocket.Request
  require Logger

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    {:ok, {ip, port}} = ThousandIsland.Socket.peername(socket)
    client = make_client_string(ip, port)
    Logger.info("New connection: #{client}")

    with request <- Request.parse(data),
         {:ok, ws_header} <- get_websocket_upgrade(request) do
      Logger.info("Websocket Update for #{client}: \n#{inspect(ws_header)}")
    else
      {:error, :no_upgrade} -> Logger.info("No upgrade for: #{client}")
    end

    {:continue, state}
  end

  def make_response_header(body) do
    "HTTP/1.1 200 OK\r\n" <>
      "content-length:#{String.length(body)}\r\n" <>
      "content-type: text; charset=utf-8\r\n" <>
      "\r\n"
  end

  def get_websocket_upgrade(header) do
    headers = Map.get(header, "headers")

    if is_websocket_upgrade(headers) do
      keys = ["sec-websocket-version", "sec-websocket-key", "sec-websocket-extensions"]

      {:ok, Enum.filter(headers, fn {key, _} -> key in keys end)}
    else
      {:error, :no_upgrade}
    end
  end

  def is_websocket_upgrade(header) do
    Enum.find(header, fn {key, value} -> key == "connection" && value == "upgrade" end) != nil
  end

  def make_client_string({ip1, ip2, ip3, ip4}, port) do
    "#{ip1}.#{ip2}.#{ip3}.#{ip4}:#{port}"
  end
end
