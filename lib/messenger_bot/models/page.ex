defmodule MessengerBot.Model.Page do
  @moduledoc """
  Structure and type for MessengerBot Page
  """

  @enforce_keys [:id, :access_token]
  defstruct [:id, :app_id, :name, :access_token, :access_token_expires_at, :metadata]

  @type t :: %__MODULE__{
          id: String.t(),
          app_id: String.t(),
          name: String.t(),
          access_token: String.t(),
          access_token_expires_at: integer(),
          metadata: map()
        }
end
