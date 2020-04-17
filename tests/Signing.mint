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
                amount = "5000",
                fee = "1",
                signr = "",
                signs = ""
              }
            ],
          recipients =
            [
              {
                address =
                  "VDBlY2I4ZjA5MTUxOWE0MTIwNTRmZjlhYTM1YjYxMjcwNjM1YzcxYjlk" \
                  "MDZhZDUx",
                amount = "5000"
              }
            ],
          message = "",
          token = "SUSHI",
          prevHash = "",
          timestamp = 0,
          scaled = 0,
          kind = "SLOW"
        }

      signedTransaction =
        Sushi.Wallet.signTransaction(
          fullWallet.privateKey,
          transaction)

      combined =
        signedTransaction.senders
        |> Array.map((s : Sender) : String { s.signr + s.signs })
        |> Array.lastWithDefault("")

      (String.size(combined) <= 128 && String.size(combined) > 64)
    } catch Wallet.Error => error {
      false
    }
  }

  test "should verify a signed transaction" {
    try {
      senderAddress =
        "VDBiMTNmNDJmNDMxZjE1ZDc0MDE1ZTRkYTQxZWI2ZWRmMjRkMTRiY2Q5M2I4MjE3"

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
                amount = "5000",
                fee = "1",
                signr = "",
                signs = ""
              }
            ],
          recipients =
            [
              {
                address =
                  "VDBlY2I4ZjA5MTUxOWE0MTIwNTRmZjlhYTM1YjYxMjcwNjM1YzcxYjlk" \
                  "MDZhZDUx",
                amount = "5000"
              }
            ],
          message = "",
          token = "SUSHI",
          prevHash = "",
          timestamp = 0,
          scaled = 0,
          kind = "SLOW"
        }

      signedTransaction =
        Sushi.Wallet.signTransaction(
          senderPrivateKey,
          transaction)

      result =
        Sushi.Wallet.verifyTransaction(senderPublicKey, transaction)

      (result == true)
    } catch Wallet.Error => error {
      false
    }
  }
}
