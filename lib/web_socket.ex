defmodule WebSocket do
  use ThousandIsland.Handler
  alias WebSocket.Handshake
  alias WebSocket.Frame

  # Client API
  def get_peername(ws_socket) do
    {:ok, {{ip1, ip2, ip3, ip4}, port}} = GenServer.call(ws_socket, :peername)
    "#{ip1}.#{ip2}.#{ip3}.#{ip4}:#{port}"
  end

  def send_message(ws_socket, message) do
    send(ws_socket, {:send, message})
  end

  # ServerAPI
  @impl ThousandIsland.Handler
  def handle_connection(_socket, [handler | _] = state) do
    IO.puts("starting handler in #{inspect(self())}")
    # handler = Enum.at(state, 0)
    {:ok, ws_socket} = handler.start_link(self())

    {:continue, {state, ws_socket}}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, {state, ws_socket}) do
    IO.puts("Island socket handle data called")

    if is_http_request?(data) do
      Handshake.handshake(data, socket)
      {:continue, {state, ws_socket}}
    else
      frame =
        data
        |> Frame.read()
        |> Frame.unmask_payload()

      send(ws_socket, {:frame, frame})

      {:continue, {state, ws_socket}}
    end
  end

  def is_http_request?(data) do
    [first_line | _] = String.split(data, "\r\n", trim: true)
    String.contains?(first_line, "HTTP")
  end

  def handle_call(:peername, _from, {socket, state}) do
    {:reply, ThousandIsland.Socket.peername(socket), {socket, state}}
  end

  def handle_info({:send, message}, {socket, state}) do
    response_frame = Frame.build_frame(:text, message)
    ThousandIsland.Socket.send(socket, response_frame)
    {:noreply, {socket, state}}
  end
end
