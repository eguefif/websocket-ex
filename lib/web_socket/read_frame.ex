defmodule WebSocket.Frame do
  defstruct frame: 0, opcode: 0, length: 0, mask: 0, payload: 0

  alias WebSocket.Frame

  def read(frame) do
    %Frame{frame: frame}
    |> get_opcode()
    |> get_length()
    |> get_mask()
    |> get_payload()
  end

  defp get_opcode(frame) do
    <<_::4, opcode::4, _::binary>> = frame.frame
    %{frame | opcode: opcode}
  end

  defp get_length(frame) do
    <<_::9, length::7, _::binary>> = frame.frame

    cond do
      length < 126 ->
        %{frame | length: length}

      length == 126 ->
        <<_::16, length::16, _::binary>> = frame.frame
        %{frame | length: length}

      length == 127 ->
        <<_::16, length::64, _::binary>> = frame.frame
        %{frame | length: length}
    end
  end

  defp get_mask(frame) do
    if is_mask?(frame.frame) do
      <<_::9, length::7, _::binary>> = frame.frame

      size_len =
        cond do
          length < 126 -> 7
          length == 126 -> 16 + 7
          length == 127 -> 7 + 64
        end

      displacement = trunc((9 + size_len) / 8)
      <<_::binary-size(displacement), mask::32, _::binary>> = frame.frame
      %{frame | mask: mask}
    else
      frame
    end
  end

  defp get_payload(frame) do
    payload_start = byte_size(frame.frame) - frame.length
    <<_::binary-size(payload_start), payload::binary>> = frame.frame
    %{frame | payload: payload}
  end

  def is_mask?(<<_::8, value::1, _::7, _::binary>>) do
    value == 1
  end

  def unmask_payload(frame) do
    "hello"
  end
end
