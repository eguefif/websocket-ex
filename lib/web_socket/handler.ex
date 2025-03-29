defmodule WebSocket.Handler do
  @moduledoc """
  If you want to send message, you can use handle_info

      ```elixir
      @impl WebSocket.Handler
      def handle_frame(payload, ws_socket) do
        IO.puts(payload)
      end

      def handle_info({:send, message}, ws_socket) do
        WebSocket.Handler.send_message(ws_socket, message)
      end
      ```
  """
  @callback handle_frame(frame :: binary(), socket :: ThousandIsland.Socket.t()) :: term()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour WebSocket.Handler
      use GenServer

      def start_link(ws_socket) do
        GenServer.start_link(__MODULE__, ws_socket)
      end

      unquote(impl_genserv())
      # unquote(impl_handler())
    end
  end

  def impl_genserv() do
    quote do
      @impl true
      def init(ws_socket) do
        {:ok, ws_socket}
      end

      @impl true
      def handle_info({:frame, frame}, ws_socket) do
        __MODULE__.handle_frame(frame, ws_socket)
        {:noreply, ws_socket}
      end
    end
  end

  def impl_handler() do
    quote do
      @impl true
      def handle_frame(_frame, _ws_socket), do: :continue
    end
  end
end
