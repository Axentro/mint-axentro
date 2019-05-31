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
          scaled = 0
        }

      signedTransaction =
        Sushi.Wallet.signTransaction(
          fullWallet.privateKey,
          transaction)

      combined =
        signedTransaction.senders
        |> Array.map((s : Sender) : String { s.signr + s.signs })
        |> Array.lastWithDefault("")

      (String.size(combined) == 128)
    } catch Wallet.Error => error {
      false
    }
  }
}
