suite "Wallet.signTransaction" {
  test "should signed and verify a transaction" {
    try {
      senderAddress =
        "VDAwZTdkZGNjYjg1NDA1ZjdhYzk1M2ExMDAzNmY5MjUyYjI0MmMwNGJjZWY4NjA3"

      senderPublicKey =
        "fd94245aeddf19464ffa1b667dea401ed0952ec5a9b4dbf9d652e81c67336c4f"

      senderPrivateKey =
        "56a647e7c817b5cbee64bc2f7a371415441dd1503f004ef12c50f0a6f17093e9"

      transaction =
        {
          id = "1",
          action = "send",
          senders =
            [
              {
                address = senderAddress,
                publicKey = senderPublicKey,
                amount = 50000,
                fee = 10000,
                signature = "0"
              }
            ],
          recipients =
            [
              {
                address = senderAddress,
                amount = 50000
              }
            ],
          message = "",
          token = "SUSHI",
          prevHash = "0",
          timestamp = 0,
          scaled = 1,
          kind = "SLOW",
          version = "V1"
        }

      signedTransaction =
        Axentro.Wallet.signTransaction(
          senderPrivateKey,
          transaction)

      result =
        Axentro.Wallet.verifyTransaction(senderPublicKey, signedTransaction)

      (result == true)
    } catch Wallet.Error => error {
      false
    }
  }
}
