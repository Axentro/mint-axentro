suite "Wallet.getWalletFromWif" {
  test "should get a wallet from a wif" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getWalletFromWif(wif)

      (wallet == fromWif)
    } catch Wallet.Error => error {
      false
    }
  }
}

suite "Wallet.getFulltWalletFromWif" {
  test "network should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getFullWalletFromWif(wif)

      (fromWif.network == Network.Kind.testNet())
    } catch Wallet.Error => error {
      false
    }
  }

  test "privateKey should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getFullWalletFromWif(wif)

      String.size(fromWif.privateKey) == 64
    } catch Wallet.Error => error {
      false
    }
  }

  test "publicKey should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getFullWalletFromWif(wif)

      (wallet.publicKey == fromWif.publicKey)
    } catch Wallet.Error => error {
      false
    }
  }

  test "wif should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getFullWalletFromWif(wif)

      (wif == fromWif.wif)
    } catch Wallet.Error => error {
      false
    }
  }

  test "address should be correct" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      fromWif =
        Sushi.Wallet.getFullWalletFromWif(wif)

      (wallet.address == fromWif.address)
    } catch Wallet.Error => error {
      false
    }
  }
}
