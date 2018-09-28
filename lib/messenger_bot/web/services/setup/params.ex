defmodule MessengerBot.Web.Service.Setup.Params do
  @moduledoc false

  alias MessengerBot.Model.Error

  defstruct [:app_id, :challenge, :mode, :verify_token]

  @type t :: %__MODULE__{
          app_id: String.t(),
          challenge: String.t(),
          mode: String.t(),
          verify_token: String.t()
        }

  @required_params ~w(hub.challenge hub.mode hub.verify_token)

  @spec build(String.t(), map()) :: {:ok, t()} | Error.t()
  def build(app_id, %{"hub.challenge" => _, "hub.mode" => _, "hub.verify_token" => _} = params) do
    setup_params = %__MODULE__{
      app_id: app_id,
      challenge: to_string(params["hub.challenge"]),
      mode: to_string(params["hub.mode"]),
      verify_token: to_string(params["hub.verify_token"])
    }

    {:ok, setup_params}
  end

  def build(app_id, params) do
    missing_params = @required_params -- Map.keys(params)
    %Error{
      app_id: app_id,
      code: :unprocessable_entity,
      details: %{missing_params: missing_params}
    }
  end
end
