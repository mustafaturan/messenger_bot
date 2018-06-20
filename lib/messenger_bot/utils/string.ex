defmodule MessengerBot.Util.String do
  @moduledoc false

  @doc """
  Generate unique id using UUID
  """
  @spec unique_id() :: String.t()
  def unique_id do
    UUID.uuid4()
  end
end
