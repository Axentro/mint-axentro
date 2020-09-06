suite "Wallet.generateKeyPair" {
  test "should generate a new keyPair successfully" {
    Axentro.Wallet.generateKeyPair()
    |> Result.isOk()
  }

  test "hexPrivateKey should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid"
          },
          Axentro.Wallet.generateKeyPair())

      (String.size(keyPair.hexPrivateKey) == 64)
    }
  }

  test "hexPublicKey should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid"
          },
          Axentro.Wallet.generateKeyPair())

      (String.size(keyPair.hexPublicKey) == 64)
    }
  }
}
