defmodule WebSocketTest do
  use ExUnit.Case
  doctest WebSocket

  describe "Handshake" do
    alias WebSocket.Handshake

    test "it creates the right response key" do
      key = "dGhlIHNhbXBsZSBub25jZQ=="
      expected = "s3pPLMBiTxaQ9kYGzzhZRbK+xOo="

      result = Handshake.make_response_key(key)
      assert expected == result
    end
  end

  describe "read_frame" do
    alias WebSocket.Frame

    test "it get the opcode" do
      frame = <<129, 133, 166, 51, 46, 40, 238, 86, 66, 68, 201>>
      result = Frame.read(frame)
      assert result.opcode == 1
    end

    test "it get the length when on two bytes lower limit" do
      # The following string is the payload. Length = 126
      # Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque p
      frame =
        <<129, 254, 0, 126, 220, 51, 50, 63, 144, 92, 64, 90, 177, 19, 91, 79, 175, 70, 95, 31,
          184, 92, 94, 80, 174, 19, 65, 86, 168, 19, 83, 82, 185, 71, 30, 31, 191, 92, 92, 76,
          185, 80, 70, 90, 168, 70, 87, 77, 252, 82, 86, 86, 172, 90, 65, 92, 181, 93, 85, 31,
          185, 95, 91, 75, 242, 19, 115, 90, 178, 86, 83, 81, 252, 80, 93, 82, 177, 92, 86, 80,
          252, 95, 91, 88, 169, 95, 83, 31, 185, 84, 87, 75, 252, 87, 93, 83, 179, 65, 28, 31,
          157, 86, 92, 90, 189, 93, 18, 82, 189, 64, 65, 94, 242, 19, 113, 74, 177, 19, 65, 80,
          191, 90, 91, 76, 252, 93, 83, 75, 179, 66, 71, 90, 252, 67>>

      result = Frame.read(frame)
      assert result.length == 126
    end

    test "it get the length for two bytes, lower limit + 1" do
      # The following string is the payload. Length = 127
      # Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque p
      frame =
        <<129, 254, 0, 127, 234, 188, 150, 161, 166, 211, 228, 196, 135, 156, 255, 209, 153, 201,
          251, 129, 142, 211, 250, 206, 152, 156, 229, 200, 158, 156, 247, 204, 143, 200, 186,
          129, 137, 211, 248, 210, 143, 223, 226, 196, 158, 201, 243, 211, 202, 221, 242, 200,
          154, 213, 229, 194, 131, 210, 241, 129, 143, 208, 255, 213, 196, 156, 215, 196, 132,
          217, 247, 207, 202, 223, 249, 204, 135, 211, 242, 206, 202, 208, 255, 198, 159, 208,
          247, 129, 143, 219, 243, 213, 202, 216, 249, 205, 133, 206, 184, 129, 171, 217, 248,
          196, 139, 210, 182, 204, 139, 207, 229, 192, 196, 156, 213, 212, 135, 156, 229, 206,
          137, 213, 255, 210, 202, 210, 247, 213, 133, 205, 227, 196, 202, 204, 247>>

      result = Frame.read(frame)
      assert result.length == 127
    end

    test "it get the payload" do
      frame = <<129, 133, 166, 51, 46, 40, 238, 86, 66, 68, 201>>
      result = Frame.read(frame)
      assert result.payload == <<238, 86, 66, 68, 201>>
    end

    test "it get the mask" do
      frame = <<129, 133, 166, 51, 46, 40, 238, 86, 66, 68, 201>>
      result = Frame.read(frame)
      message = Frame.unmask_payload(frame)
      assert message == "Hello2"
    end

    test "is_mask?" do
      frame = <<129, 133, 166, 51, 46, 40, 238, 86, 66, 68, 201>>
      assert Frame.is_mask?(frame) == true
    end
  end
end
