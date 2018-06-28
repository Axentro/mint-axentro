suite "Wallet.isValidAddress" {
  test "true when valid" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      address =
        wallet.address

      isValid =
        Sushi.Wallet.isValidAddress(address)

      (isValid == true)
    } catch Wallet.Error => error {
      false
    }
  }

  test "false when invalid" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      address =
        wallet.address

      isValid =
        Sushi.Wallet.isValidAddress("dffddfaf")

      (isValid == false)
    } catch Wallet.Error => error {
      false
    }
  }
}
