suite "Wallet.generateKeyPair" {
  test "should generate a new keyPair successfully" {
    Sushi.Wallet.generateKeyPair()
    |> Result.isOk()
  }

  test "hexPrivateKey should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid",
            hexPublicKeyX = "invalid",
            hexPublicKeyY = "invalid"
          },
          Sushi.Wallet.generateKeyPair())

      (String.size(keyPair.hexPrivateKey) == 64)
    }
  }

  test "hexPublicKey should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid",
            hexPublicKeyX = "invalid",
            hexPublicKeyY = "invalid"
          },
          Sushi.Wallet.generateKeyPair())

      (String.size(keyPair.hexPublicKey) == 128)
    }
  }

  test "hexPublicKeyX should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid",
            hexPublicKeyX = "invalid",
            hexPublicKeyY = "invalid"
          },
          Sushi.Wallet.generateKeyPair())

      (String.size(keyPair.hexPublicKeyX) == 64)
    }
  }

  test "hexPublicKeyY should be correct length" {
    try {
      keyPair =
        Result.withDefault(
          {
            hexPrivateKey = "invalid",
            hexPublicKey = "invalid",
            hexPublicKeyX = "invalid",
            hexPublicKeyY = "invalid"
          },
          Sushi.Wallet.generateKeyPair())

      (String.size(keyPair.hexPublicKeyY) == 64)
    }
  }
}

suite "Wallet.generateNewWallet" {
  test "should generate a new wallet successfully" {
    Sushi.Wallet.generateNewWallet("T0")
    |> Result.isOk()
  }

  test "go" {
    try {
      w =
        Sushi.Wallet.generateNewWallet("T0")

      Debug.log(w.publicKey)
      w.publicKey == "faf"
    } catch Wallet.Error => error {
      try {
        false
      }
    }
  }
}
