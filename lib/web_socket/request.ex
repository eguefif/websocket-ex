defmodule WebSocket.Request do
  def parse(data) do
    # , trim: true)
    [first_line | headers] = String.split(data, "\r\n", trim: true)
    request_line = parse_first_line(first_line)

    %{
      "method" => request_line["method"],
      "uri" => request_line["uri"],
      "version" => request_line["version"],
      "headers" => parse_headers(headers)
    }
  end

  def parse_first_line(line) do
    splits = String.split(line, " ")

    %{
      "method" => Enum.at(splits, 0),
      "uri" => Enum.at(splits, 1),
      "version" => Enum.at(splits, 2)
    }
  end

  def parse_headers(headers) do
    headers
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&parse_one_header/1)
    |> Enum.filter(fn entry -> tuple_size(entry) != 0 end)
  end

  def parse_one_header(header) do
    case String.split(header, ":") do
      [key, value] -> {String.trim(key), String.trim(value)}
      _ -> {}
    end
  end

  def display(header) do
    require Logger
    IO.puts(inspect("****HTTP Request****"))
    IO.puts(inspect("#{header["method"]} #{header["uri"]} #{header["version"]}"))

    header["headers"]
    |> Enum.each(fn header ->
      IO.puts(inspect("#{elem(header, 0)}: #{elem(header, 1)}"))
    end)

    IO.puts("****Request end****")
  end

  def to_string(header) do
    retval = "#{header["method"]} #{header["uri"]} #{header["version"]}\n\n"

    header["headers"]
    |> Enum.reduce(retval, fn header, acc ->
      acc <> "#{elem(header, 0)}: #{elem(header, 1)}\n"
    end)
  end
end
