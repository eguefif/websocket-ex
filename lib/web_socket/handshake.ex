defmodule WebSocket.Handshake do
  alias WebSocket.Request
  require Logger

  @ws_guid "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

  def handshake(data, socket) do
    {:ok, {ip, port}} = ThousandIsland.Socket.peername(socket)
    client = make_client_string(ip, port)
    Logger.info("New connection: #{client}")

    with request <- Request.parse(data),
         {:ok, ws_header} <- get_websocket_upgrade(request),
         :ok <- make_websocket_handshake(ws_header, socket) do
      Logger.info("Websocket upgrade for #{client}: \n#{inspect(ws_header)}")
    else
      {:error, :no_upgrade} -> Logger.info("No upgrade for: #{client}")
    end
  end

  def get_websocket_upgrade(header) do
    headers = Map.get(header, "headers")

    if is_websocket_upgrade(headers) do
      keys = ["Sec-WebSocket-Version", "Sec-WebSocket-Key", "Sec-WebSocket-Extensions"]

      {:ok, Enum.filter(headers, fn {key, _} -> key in keys end)}
    else
      {:error, :no_upgrade}
    end
  end

  def is_websocket_upgrade(header) do
    Enum.find(header, fn {key, value} -> key == "Connection" && value == "Upgrade" end) != nil
  end

  def make_client_string({ip1, ip2, ip3, ip4}, port) do
    "#{ip1}.#{ip2}.#{ip3}.#{ip4}:#{port}"
  end

  def make_websocket_handshake(ws_header, socket) do
    key =
      ws_header
      |> Enum.find(fn {key, _} -> key == "Sec-WebSocket-Key" end)
      |> elem(1)
      |> String.trim()

    response_key = make_response_key(key)
    response_header = make_response_header(response_key)
    Logger.info("Sending response: \n#{inspect(response_header, charlists: :as_charlists)}")
    ThousandIsland.Socket.send(socket, response_header)
    IO.puts("TEST")
    :ok
  end

  def make_response_key(key) do
    :crypto.hash(:sha, key <> @ws_guid)
    |> Base.encode64()
  end

  def make_response_header(key) do
    "HTTP/1.1 101 Switching Protocols\r\n" <>
      "Upgrade: websocket\r\n" <>
      "Connection: Upgrade\r\n" <>
      "Sec-WebSocket-Accept: #{key}\r\n" <>
      "\r\n"
  end
end
