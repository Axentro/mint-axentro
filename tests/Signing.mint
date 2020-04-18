suite "Wallet.signTransaction" {
  test "should sign a transaction" {
    try {
      wallet =
        Sushi.Wallet.generateNewWallet(Network.Prefix.testNet())

      fullWallet =
        Sushi.Wallet.getFullWalletFromWif(wallet.wif)

      transaction =
        {
          id = "1",
          action = "send",
          senders =
            [
              {
                address = wallet.address,
                publicKey = wallet.publicKey,
                amount = 50000,
                fee = 10000,
                signr = "0",
                signs = "0"
              }
            ],
          recipients =
            [
              {
                address =
                  "VDBlY2I4ZjA5MTUxOWE0MTIwNTRmZjlhYTM1YjYxMjcwNjM1YzcxYjlk" \
                  "MDZhZDUx",
                amount = 50000
              }
            ],
          message = "",
          token = "SUSHI",
          prevHash = "0",
          timestamp = 0,
          scaled = 1,
          kind = "SLOW"
        }

      signedTransaction =
        Sushi.Wallet.signTransaction(
          fullWallet.privateKey,
          transaction)

      combined =
        signedTransaction.senders
        |> Array.map((s : ScaledSender) : String { s.signr + s.signs })
        |> Array.lastWithDefault("")

      (String.size(combined) <= 128 && String.size(combined) > 64)
    } catch Wallet.Error => error {
      false
    }
  }

  test "should verify a signed transaction" {
    try {
      senderAddress =
        "VDBkN2FmYzljY2QzOTM2NWQ2NjdmMzA1MmY4ZTM4ZTc2MDgyMjY4ZWFhZTU3YmJh"

      senderPublicKey =
        "04cbca172be23b65ecd2ac5c84f15fd82640421b01b502e3df2f225e51d286273396b63648cfc98b7b93f6e86a49147bcaf6b8c0cdbe370e66d9bbcabe8d2c5630"

      senderPrivateKey =
        "8d521bbad35ed79edc045b3ac9cab6e0e004ab2508bb56e8573cfea4f1c1ad07"

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
                signr = "0",
                signs = "0"
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
          kind = "SLOW"
        }

      signedTransaction =
        Sushi.Wallet.signTransaction(
          senderPrivateKey,
          transaction)

      result =
        Sushi.Wallet.verifyTransaction(senderPublicKey, signedTransaction)

      (result == true)
    } catch Wallet.Error => error {
      false
    }
  }
}
