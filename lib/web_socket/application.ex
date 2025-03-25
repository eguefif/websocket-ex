defmodule WebSocket.Application do
  use Application

  @impl true
  def start(_type, _args) do
    ThousandIsland.start_link(port: 8000, handler_module: WebSocket)
  end
end
