defmodule WebSocket.Supervisor do
  def init(_config) do
    children = [
      {ThousandIsland, port: 1234, handler_module: WebSocket.ConnectionHandler}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
