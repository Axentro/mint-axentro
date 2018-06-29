suite "Wallet.generateNewWallet" {
  test "should generate a new wallet successfully" {
    Sushi.Wallet.generateNewWallet("T0")
    |> Result.isOk()
  }

  test "publicKey should be correct length" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      (String.size(wallet.publicKey) == 128)
    } catch Wallet.Error => error {
      try {
        false
      }
    }
  }

  test "wif should be correct length" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      (String.size(wallet.wif) == 96)
    } catch Wallet.Error => error {
      try {
        false
      }
    }
  }

  test "address should be correct length" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      (String.size(wallet.address) == 64)
    } catch Wallet.Error => error {
      try {
        false
      }
    }
  }
}
