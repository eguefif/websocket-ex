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
      frame = Frame.read(data)
      payload = Frame.unmask_payload(frame)
      Logger.info("Payload: #{payload}")
      {:continue, state}
    end
  end

  def is_http_request?(data) do
    [first_line | _] = String.split(data, "\r\n", trim: true)
    String.contains?(first_line, "HTTP")
  end

  def handle_call({:send, message}, _from, {socket, state}) do
    response_frame = Frame.build_frame(:text, message)
    ThousandIsland.Socket.send(socket, response_frame)
    {:reply, :ok, {socket, state}}
  end
end
