defmodule WebSocket.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ThousandIsland, port: 8000, handler_module: WebSocket},
      {Registry, keys: :duplicate, name: Registry.WS}
    ]

    opts = [strategy: :one_for_one, name: WS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
