defmodule MessengerBot.Util.JSON do
  @moduledoc false

  @decode_opts [:return_maps]

  alias :jiffy, as: Jiffy

  @doc """
  Encode
  """
  @spec encode(any) :: {:ok, String.t()} | {:error, tuple()}
  def encode(nil) do
    {:ok, nil}
  end

  def encode(payload) do
    {:ok, Jiffy.encode(payload)}
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
  @spec decode(String.t() | nil) :: {:ok, map() | list()} | {:error, tuple()}
  def decode(payload) do
    {:ok, Jiffy.decode("#{payload}", @decode_opts)}
  catch
    {:error, reason} -> {:error, reason}
  end
end
