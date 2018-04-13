defmodule MessengerBot.PayloadFixtures do
  @moduledoc false

  @doc false
  def load(file_prefix) do
    path = Path.expand("./fixtures/#{file_prefix}.json", __DIR__)
    File.read!(path)
  end
end
