defmodule MessengerBot.Model.App do
  @moduledoc """
  Structure and type for MessengerBot App
  """

  @enforce_keys [:id, :secret, :setup_token]
  defstruct [:access_token, :access_token_expires_at, :id, :metadata, :name, :secret, :setup_token]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          secret: String.t(),
          setup_token: String.t(),
          access_token: String.t(),
          access_token_expires_at: integer(),
          metadata: map()
        }
end
