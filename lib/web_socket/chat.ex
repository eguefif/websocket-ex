defmodule Chat do
  use WebSocket.Handler
  require Logger

  @impl WebSocket.Handler
  def handle_frame(frame, ws_socket) do
    if !is_registered_client?(ws_socket) do
      peername = WebSocket.get_peername(ws_socket)
      Registry.register(Registry.Clients, :broadcast, peername)
    end

    with {:ok, command} <- parse_payload(frame) do
      Logger.debug("New frame: #{frame}")
      run_cmd(command, ws_socket)
    else
      {:error, e} -> WebSocket.send_message(ws_socket, "Error: #{e}")
    end

    :continue
  end

  def is_registered_client?(ws_socket) do
    peername = WebSocket.get_peername(ws_socket)
    peername in Registry.values(Registry.Clients, :broadcast, self())
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
    Logger.debug("Peername #{peername}")
    Registry.register(Registry.Clients, peername, name)
  end

  def run_cmd({:msg, message}, ws_socket) do
    Logger.debug("New message: #{message}")
    peername = WebSocket.get_peername(ws_socket)
    Logger.debug("Peername #{peername}")

    name =
      case Registry.lookup(Registry.Clients, peername) do
        [{_, name}] -> name
        _ -> "Anonymous"
      end

    Registry.dispatch(Registry.Clients, :broadcast, fn clients ->
      for {pid, _} <- clients, do: send(pid, {:send, name <> ": " <> message})
    end)
  end

  def handle_info({:send, message}, ws_socket) do
    WebSocket.send_message(ws_socket, message)
    {:noreply, ws_socket}
  end
end
