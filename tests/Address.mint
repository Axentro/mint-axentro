suite "Wallet.isValidAddress" {
  test "true when valid" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      address =
        wallet.address

      isValid =
        Axentro.Wallet.isValidAddress(address)

      (isValid == true)
    } catch Wallet.Error => error {
      false
    }
  }

  test "false when invalid" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      address =
        wallet.address

      isValid =
        Axentro.Wallet.isValidAddress("dffddfaf")

      (isValid == false)
    } catch Wallet.Error => error {
      false
    }
  }
}
