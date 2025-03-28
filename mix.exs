defmodule WebSocket.MixProject do
  use Mix.Project

  def project do
    [
      app: :web_socket,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {WebSocket.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:thousand_island, "~> 1.3.12"}
    ]
  end
end
