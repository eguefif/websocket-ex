defmodule Chat do
  use WebSocket.Handler
  require Logger

  @impl WebSocket.Handler
  def handle_frame(frame, ws_socket) do
    with {:ok, command} <- parse_payload(frame) do
      run_cmd(command, ws_socket)
    else
      {:error, e} -> WebSocket.send_message(ws_socket, "Error: #{e}")
    end

    :continue
  end

  def parse_payload(payload) do
    case String.split(payload, " ", parts: 2) do
      ["NAME", name] -> {:ok, {:name, name}}
      ["MSG", msg] -> {:ok, {:msg, msg}}
      _ -> {:error, "Unknown command"}
    end
  end

  def run_cmd({:name, name}, ws_socket) do
    Logger.info("New client: #{name}")
    peername = WebSocket.get_peername(ws_socket)
    Registry.register(Registry.Clients, peername, name)
    Registry.register(Registry.Clients, :broadcast, [])
  end

  def run_cmd({:msg, message}, ws_socket) do
    peername = WebSocket.get_peername(ws_socket)
    [{_, name}] = Registry.lookup(Registry.Clients, peername)

    Registry.dispatch(Registry.Clients, :broadcast, fn clients ->
      for {pid, _} <- clients, do: send(pid, {:send, name <> ": " <> message})
    end)
  end

  def handle_info({:send, message}, ws_socket) do
    WebSocket.send_message(ws_socket, message)
    {:noreply, ws_socket}
  end
end
