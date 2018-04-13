defmodule MessengerBot.Util.JSON do
  @moduledoc false

  @regexp ~r/((,?)\"__struct__\":\"([^\"]+)\"(,?))|(\"([^\"]+)\":\"nil\"(,?))/
  @decode_opts [:return_maps]

  alias :jiffy, as: Jiffy

  @doc """
  Encode
  """
  @spec encode(any) :: {:ok, Strint.t()} | {:error, tuple()}
  def encode(payload) do
    {:ok, Regex.replace(@regexp, Jiffy.encode(payload), "")}
  catch
    {:error, reason} -> {:error, reason}
  end

  def encode!(payload) do
    {:ok, json} = encode(payload)
    json
  end

  @doc """
  Decode
  """
  @spec decode(String.t() | nil) :: {:ok, Map.t() | list()} | {:error, tuple()}
  def decode(payload) do
    {:ok, Jiffy.decode("#{payload}", @decode_opts)}
  catch
    {:error, reason} -> {:error, reason}
  end
end
