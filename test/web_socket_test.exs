defmodule WebSocketTest do
  use ExUnit.Case
  doctest WebSocket
  alias WebSocket

  test "it creates the right response key" do
    key = "dGhlIHNhbXBsZSBub25jZQ=="
    expected = "s3pPLMBiTxaQ9kYGzzhZRbK+xOo="

    result = WebSocket.make_response_key(key)
    assert expected == result
  end
end
