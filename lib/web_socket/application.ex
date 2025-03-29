defmodule WebSocket.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ThousandIsland, port: 8000, handler_module: WebSocket},
      {Registry, keys: :unique, name: Registry.WS},
      {Registry, keys: :duplicate, name: Registry.Clients}
    ]

    opts = [strategy: :one_for_one, name: WS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
