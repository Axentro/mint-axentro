suite "Wallet.signTransaction" {
  test "should sign and verify a transaction using private key" {
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
          assets =
            [
              {
                assetId = "dd0682e21dffaa39ecc23074c483c07d4524f0f2fce065687a78d7ec51fefdf5",
                name = "my asset",
                description = "my asset description",
                mediaLocation = "https://axentro.io",
                mediaHash = "",
                quantity = 1,
                terms = "",
                locked = "UNLOCKED",
                version = 1,
                timestamp = 1615971474028
              }
            ],
          modules = [],
          inputs = [],
          outputs = [],
          linked = "",
          message = "",
          token = "AXNT",
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

  test "should sign and verify a transaction using wif" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      wif =
        wallet.wif

      senderAddress = wallet.address

      senderPublicKey = wallet.publicKey  

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
          assets =
            [
              {
                assetId = "dd0682e21dffaa39ecc23074c483c07d4524f0f2fce065687a78d7ec51fefdf5",
                name = "my asset",
                description = "my asset description",
                mediaLocation = "https://axentro.io",
                mediaHash = "",
                quantity = 1,
                terms = "",
                locked = "UNLOCKED",
                version = 1,
                timestamp = 1615971474028
              }
            ],
          modules = [],
          inputs = [],
          outputs = [],
          linked = "",
          message = "",
          token = "AXNT",
          prevHash = "0",
          timestamp = 0,
          scaled = 1,
          kind = "SLOW",
          version = "V1"
        }

      signedTransaction =
        Axentro.Wallet.signTransactionWithWif(
          wif,
          transaction)

      result =
        Axentro.Wallet.verifyTransaction(senderPublicKey, signedTransaction)

      (result == true)
    } catch Wallet.Error => error {
      false
    }
  }
}
