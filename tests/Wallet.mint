suite "Wallet.generateKeyPair" {
  test "should generate a new keyPair" {
    try {
      keyPair =
        Wallet.generateKeyPair()

      (String.size(keyPair.hexPublicKey) == 12)
    } catch KeyPair.Error => error {
      false
    }
  }
}
