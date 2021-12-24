suite "Transactions.generateId" {
  test "should generate a 32 random secure hex id" {
    try {
      id =
        Axentro.Transactions.generateId()

      ((id
      |> String.size) == 64)
    } catch Transactions.Error => error {
      false
    }
  }
}

suite "Amount scaling" {
  test "should unscale scaled amount" {
    try {
      amount =
        Axentro.Transactions.toUnscaledAmount(50000)

      (amount == "0.0005")
    } catch Transactions.Error => error {
      false
    }
  }

  test "should scale unscaled amount" {
    try {
      amount =
        Axentro.Transactions.toScaledAmount("0.0005")

      (amount == 50000)
    } catch Transactions.Error => error {
      false
    }
  }

  test "should scale senders" {
    try {
      senderAddress =
        "VDAwZTdkZGNjYjg1NDA1ZjdhYzk1M2ExMDAzNmY5MjUyYjI0MmMwNGJjZWY4NjA3"

      senderPublicKey =
        "fd94245aeddf19464ffa1b667dea401ed0952ec5a9b4dbf9d652e81c67336c4f"

      senders =
        [
          {
            address = senderAddress,
            publicKey = senderPublicKey,
            amount = "5",
            fee = "0.0001",
            signature = "0"
          }
        ]

      scaledSenders =
        Axentro.Transactions.toScaledSenders(senders)

      expectedSenders =
        [
          {
            address = senderAddress,
            publicKey = senderPublicKey,
            amount = 500000000,
            fee = 10000,
            signature = "0"
          }
        ]

      (scaledSenders == expectedSenders)
    }
  }

  test "should scale recipients" {
    try {
      recipientAddress =
        "VDAwZTdkZGNjYjg1NDA1ZjdhYzk1M2ExMDAzNmY5MjUyYjI0MmMwNGJjZWY4NjA3"

      recipients =
        [
          {
            address = recipientAddress,
            amount = "5"
          }
        ]

      scaledRecipients =
        Axentro.Transactions.toScaledRecipients(recipients)

      expectedRecipients =
        [
          {
            address = recipientAddress,
            amount = 500000000
          }
        ]

      (scaledRecipients == expectedRecipients)
    }
  }

  test "should unscale senders" {
    try {
      senderAddress =
        "VDAwZTdkZGNjYjg1NDA1ZjdhYzk1M2ExMDAzNmY5MjUyYjI0MmMwNGJjZWY4NjA3"

      senderPublicKey =
        "fd94245aeddf19464ffa1b667dea401ed0952ec5a9b4dbf9d652e81c67336c4f"

      senders =
        [
          {
            address = senderAddress,
            publicKey = senderPublicKey,
            amount = 500000000,
            fee = 10000,
            signature = "0"
          }
        ]

      unscaledSenders =
        Axentro.Transactions.toUnscaledSenders(senders)

      expectedSenders =
        [
          {
            address = senderAddress,
            publicKey = senderPublicKey,
            amount = "5",
            fee = "0.0001",
            signature = "0"
          }
        ]

      (unscaledSenders == expectedSenders)
    }
  }

  test "should unscale recipients" {
    try {
      recipientAddress =
        "VDAwZTdkZGNjYjg1NDA1ZjdhYzk1M2ExMDAzNmY5MjUyYjI0MmMwNGJjZWY4NjA3"

      recipients =
        [
          {
            address = recipientAddress,
            amount = 500000000
          }
        ]

      unscaledRecipients =
        Axentro.Transactions.toUnscaledRecipients(recipients)

      expectedRecipients =
        [
          {
            address = recipientAddress,
            amount = "5"
          }
        ]

      (unscaledRecipients == expectedRecipients)
    }
  }
}

suite "Transaction scaling" {
  test "should scale an unscaled transaction" {
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
                amount = "5",
                fee = "0.0001",
                signature = "0"
              }
            ],
          recipients =
            [
              {
                address = senderAddress,
                amount = "5"
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
          scaled = 0,
          kind = "SLOW",
          version = "V1"
        }

      expectedTransaction =
        {
          id = "1",
          action = "send",
          senders =
            [
              {
                address = senderAddress,
                publicKey = senderPublicKey,
                amount = 500000000,
                fee = 10000,
                signature = "0"
              }
            ],
          recipients =
            [
              {
                address = senderAddress,
                amount = 500000000
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

      scaledTransaction =
        Axentro.Transactions.toScaledTransaction(transaction)

      (scaledTransaction == expectedTransaction)
    }
  }

  test "should unscale an scaled transaction" {
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
                amount = 500000000,
                fee = 10000,
                signature = "0"
              }
            ],
          recipients =
            [
              {
                address = senderAddress,
                amount = 500000000
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

      expectedTransaction =
        {
          id = "1",
          action = "send",
          senders =
            [
              {
                address = senderAddress,
                publicKey = senderPublicKey,
                amount = "5",
                fee = "0.0001",
                signature = "0"
              }
            ],
          recipients =
            [
              {
                address = senderAddress,
                amount = "5"
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
          scaled = 0,
          kind = "SLOW",
          version = "V1"
        }

      unscaledTransaction =
        Axentro.Transactions.toUnscaledTransaction(transaction)

      (unscaledTransaction == expectedTransaction)
    }
  }
}

suite "Transaction - create send amount" {
  test "should create send amount scaled transaction" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      recipientWallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      toAddress =
        recipientWallet.address

      transaction =
        Axentro.Transactions.createSendAxntScaledTransactionFromWallet(toAddress, "1", wallet)

      signedTransaction =
        Axentro.Wallet.signTransactionWithWif(
          wallet.wif,
          transaction)

      result =
        Axentro.Wallet.verifyTransaction(wallet.publicKey, signedTransaction)

      (result == true)
    } catch {
      false
    }
  }
}
