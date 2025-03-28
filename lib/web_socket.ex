defmodule WebSocket do
  require Logger
  use ThousandIsland.Handler
  alias WebSocket.Handshake
  alias WebSocket.Frame

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    if is_http_request?(data) do
      Handshake.handshake(data, socket)
      {:continue, state}
    else
      with frame <- Frame.read(data),
           payload <- Frame.unmask_payload(frame),
           command <- parse_payload(payload) do
        run_cmd(command, socket)
        {:continue, state}
      end
    end
  end

  def parse_payload(payload) do
    case String.split(payload, " ") do
      ["NAME", name] -> {:name, name}
      ["MSG", msg] -> {:msg, msg}
      _ -> {:error, "Unknown command"}
    end
  end

  def run_cmd({:name, name}, socket) do
    peername = get_peername(socket)
    client = {:via, Registry, {Registry.WS, peername, name}}
    Agent.start_link(fn -> [] end, name: client)
    Registry.register(Registry.WS, :broadcast, [])
    Logger.info("New client: #{name}")
  end

  def run_cmd({:msg, message}, socket) do
    peername = get_peername(socket)
    [{_, name}] = Registry.lookup(Registry.WS, peername)

    Registry.dispatch(Registry.WS, :broadcast, fn clients ->
      for {pid, _} <- clients, do: send(pid, {:send, name <> ": " <> message})
    end)
  end

  def is_http_request?(data) do
    [first_line | _] = String.split(data, "\r\n", trim: true)
    String.contains?(first_line, "HTTP")
  end

  def get_peername(socket) do
    {:ok, {{ip1, ip2, ip3, ip4}, port}} = ThousandIsland.Socket.peername(socket)
    "#{ip1}.#{ip2}.#{ip3}.#{ip4}:#{port}"
  end

  def handle_info({:send, message}, {socket, state}) do
    peername = get_peername(socket)
    [{_, name}] = Registry.lookup(Registry.WS, peername)
    Logger.info("Sending #{message} to #{name}")
    response_frame = Frame.build_frame(:text, message)
    ThousandIsland.Socket.send(socket, response_frame)
    {:noreply, {socket, state}}
  end
end
