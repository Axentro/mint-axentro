/* This test is used to check sending is working but until the testnet is up again is commented out 

module Test.Error.Helper {
  fun go (error : String) : Bool {
    try {
      Debug.log(error)
      false
    }
  }
}

component FailedTest {
  fun render {
    <div/>
  }
}

component SendTest {
  state result : String = "pending"
  property url : String
  property transaction : ScaledTransaction
  property wallet : Wallet

  fun clickMe (e : Html.Event) {
    sequence {
      signedTransaction =
        Axentro.Wallet.signTransactionWithWif(
          wallet.wif,
          transaction)

      Axentro.ApiUtil.sendTransaction(url, signedTransaction, (value : String) : Promise(Never, Void) { next { result = "passed" } }, (error : String) : Promise(Never, Void) { next { result = "failed " + error } })
    } catch {
      next { result = "failed for unknown reason" }
    }
  }

  fun render {
    <div>
      <button
        type="button"
        onClick={clickMe}>

        "Click Me"

      </button>

      <b>
        <{ result }>
      </b>
    </div>
  }
}

suite "Axentro.ApiUtil" {
  test "should send transaction" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      transaction =
        Axentro.Transactions.createSendAxntScaledTransactionFromWallet(wallet.address, "0.0001", wallet)

      with Test.Html {
        <SendTest
          url="https://testnet.axentro.io/api/v1/transaction"
          transaction={transaction}
          wallet={wallet}/>
        |> start()
        |> triggerClick("button")
        |> Test.Context.timeout(500)
        |> assertTextOf("b", "passed")
      }
    } catch {
      with Test.Html {
        <FailedTest/>
        |> start()
        |> assertTextOf("b", "passed")
      }
    }
  }

  test "should send asset transaction" {
    try {
      wallet =
        Axentro.Wallet.generateNewWallet(Network.Prefix.testNet())

      assetId =
        Axentro.Transactions.generateId()

      transaction =
        Axentro.Transactions.createAssetScaledTransactionFromWallet(assetId, "name", "description", "http://axentro.io", wallet)

      with Test.Html {
        <SendTest
          url="http://testnet/api/v1/transaction"
          transaction={transaction}
          wallet={wallet}/>
        |> start()
        |> triggerClick("button")
        |> Test.Context.timeout(500)
        |> assertTextOf("b", "passed")
      }
    } catch {
      with Test.Html {
        <FailedTest/>
        |> start()
        |> assertTextOf("b", "passed")
      }
    }
  }
}

*/
