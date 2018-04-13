defmodule MessengerBot.Util.Encryption do
  @moduledoc false

  alias :crypto, as: Crypto

  @type err :: {:error, Map.t()}
  @type res :: :ok | err()

  @doc """
  Validate sha1 signature for given text
  """
  @spec validate_sha1(String.t(), String.t(), String.t()) :: res()
  def validate_sha1(secret, body, signature) do
    case signature == calculate_sha1(secret, body) do
      true -> :ok
      false -> {:error, %{signature: "invalid"}}
    end
  end

  @doc """
  Calculate sha256
  """
  @spec calculate_sha256(String.t(), String.t()) :: String.t()
  def calculate_sha256(secret, body) do
    calculate_sha(:sha256, secret, body)
  end

  defp calculate_sha1(secret, body) do
    calculate_sha(:sha, secret, body)
  end

  defp calculate_sha(alg, secret, body) do
    alg
    |> Crypto.hmac("#{secret}", "#{body}")
    |> Base.encode16()
    |> String.downcase()
  end
end
