defmodule MessengerBot.Model.Error do
  @moduledoc """
  Structure and type for MessengerBot Error
  """

  @enforce_keys [:code, :details]
  defstruct [:app_id, :page_id, :code, :details]

  @type t :: %__MODULE__{
          app_id: String.t() | nil,
          page_id: String.t() | nil,
          code: atom() | integer(),
          details: map()
        }
end
