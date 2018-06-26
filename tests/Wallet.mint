suite "Wallet.generateKeyPair" {
  test "should generate a new keyPair successfully" {
    Wallet.generateKeyPair()
    |> Result.isOk()
  }
  test "should generate a new keyPair with correct key lengths" {

    Result.withDefault({hexPrivateKey = "invalid",hexPublicKey = "invalid",hexPublicKeyX = "invalid", hexPublicKeyY = "invalid"}, Wallet.generateKeyPair())
  }
}
