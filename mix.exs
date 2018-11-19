defmodule MessengerBot.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :messenger_bot,
      version: "1.3.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.html": :test]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger, :crypto, :event_bus, :tesla],
      mod: {MessengerBot.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:event_bus, ">= 1.6.0"},
      {:tesla, ">= 1.0.0"},
      {:plug, ">= 1.4.0"},
      {:uuid, "~> 1.1"},
      {:jiffy, "~> 0.15"},
      {:mock, "~> 0.3", only: [:test]},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.19.1", only: :dev},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description do
    """
    Unofficial Facebook Messenger Platform chatbot client and webhook handler
    """
  end

  defp package do
    [
      name: :messenger_bot,
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Mustafa Turan"],
      licenses: ["LGPLv3"],
      links: %{"GitHub" => "https://github.com/mustafaturan/messenger_bot"}
    ]
  end
end
