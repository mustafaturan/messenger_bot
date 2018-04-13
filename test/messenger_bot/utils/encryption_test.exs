defmodule MessengerBot.Util.EncryptionTest do
  use ExUnit.Case
  alias MessengerBot.Util.Encryption
  doctest Encryption

  test ".validate_sha1 with valid signature" do
    result =
      Encryption.validate_sha1(
        "SECRET",
        "123",
        "8a895cdc3e48ce1fab4ffdcd89b557d1218bc3ba"
      )

    assert result == :ok
  end

  test ".validate_sha1 returns error tuple when invalid signature" do
    result = Encryption.validate_sha1("SECRET", "123", "wrongone")
    assert result == {:error, %{signature: "invalid"}}
  end

  test ".calculate_sha256 returns correct signature" do
    result = Encryption.calculate_sha256("SECRET", "123456")
    assert result == "c940cff1b8e5e1d8450e337d7d00b49766b5bc895041eac9691654c38e94e8b1"
  end
end
