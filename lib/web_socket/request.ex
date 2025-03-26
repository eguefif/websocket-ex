defmodule WebSocket.Request do
  def parse(data) do
    [first_line | headers] = String.split(data, "\r\n", trim: true)
    request_line = parse_first_line(first_line)

    retval = %{
      "method" => request_line["method"],
      "uri" => request_line["uri"],
      "version" => request_line["version"],
      "headers" => parse_headers(headers)
    }

    display(retval)
    retval
  end

  def parse_first_line(line) do
    splits = String.split(line, " ")

    %{
      "method" => Enum.at(splits, 0),
      "uri" => Enum.at(splits, 1),
      "version" => Enum.at(splits, 2)
    }
  end

  defp parse_headers(headers) do
    headers
    |> Enum.map(&parse_one_header/1)
    |> Enum.filter(fn entry -> tuple_size(entry) != 0 end)
  end

  defp parse_one_header(header) do
    case String.split(header, ":") do
      [key, value] -> {String.trim(key), String.trim(value)}
      _ -> {}
    end
  end

  defp display(header) do
    require Logger
    IO.puts(inspect("****HTTP Request****"))
    IO.puts(inspect("#{header["method"]} #{header["uri"]} #{header["version"]}"))

    header["headers"]
    |> Enum.each(fn header ->
      IO.puts(inspect("#{elem(header, 0)}: #{elem(header, 1)}"))
    end)

    IO.puts("****Request end****")
  end
end
