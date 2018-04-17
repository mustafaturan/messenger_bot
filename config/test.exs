use Mix.Config

config :messenger_bot,
  pages: %{
    "1881" => %{
      "1234" => %{
        id: "1234",
        name: "Demo Facebook Messenger Bot",
        access_token: "accesstokenforpage"
      }
    }
  },
  apps: %{
    "1881" => %{
      id: "1881",
      secret: "SECRET",
      setup_token: "Setup Token",
      access_token: "ATOKEN123"
    }
  }
