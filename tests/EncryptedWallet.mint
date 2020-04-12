suite "Wallet.encryptWallet" {
  test "source should be correct" {
    try {
      (Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())
      |> Result.flatMap(
        (w : Wallet) : Result(Wallet.Error, EncryptedWallet) { Sushi.Wallet.encryptWallet(w, "name", "password") })
      |> Result.map((e : EncryptedWallet) : String { e.source })
      |> Result.withDefault("")) == "kajiki"
    }
  }

  test "address should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      address =
        wallet.address

      encrypted =
        Sushi.Wallet.encryptWallet(wallet, "name", "password")

      (address == encrypted.address)
    } catch Wallet.Error => error {
      false
    }
  }

  test "ciphertext should be correct" {
    try {
      (Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())
      |> Result.flatMap(
        (w : Wallet) : Result(Wallet.Error, EncryptedWallet) { Sushi.Wallet.encryptWallet(w, "name", "password") })
      |> Result.map((e : EncryptedWallet) : String { e.ciphertext })
      |> Result.withDefault("")) != ""
    }
  }

  test "salt should be correct" {
    try {
      (Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())
      |> Result.flatMap(
        (w : Wallet) : Result(Wallet.Error, EncryptedWallet) { Sushi.Wallet.encryptWallet(w, "name", "password") })
      |> Result.map((e : EncryptedWallet) : String { e.salt })
      |> Result.withDefault("")) != ""
    }
  }
}

suite "Wallet.decryptWallet" {
  test "wallet should decrypt correctly" {
    try {
      password =
        "password"

      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      encrypted =
        Sushi.Wallet.encryptWallet(wallet, "name", password)

      decrypted =
        Sushi.Wallet.decryptWallet(encrypted, password)

      (wallet == decrypted)
    } catch Wallet.Error => error {
      false
    }
  }
}
