record Axentro.Api.ResponseStatus {
  status : String
}

record Axentro.Api.Error {
  status : String,
  reason : String
}

record Axentro.Api.Transaction.Wrapper {
  transaction : ScaledTransaction
}

module Axentro.ApiUtil {
  fun sendTransaction (
    url : String,
    signedTransaction : ScaledTransaction,
    successCallback : Function(String, Promise(Never, Void)),
    failureCallback : Function(String, Promise(Never, Void))
  ) : Promise(Never, Void) {
    sequence {
      signedTransactionRequest =
        { transaction = signedTransaction }

      encodedSignedTransaction =
        encode signedTransactionRequest

      response =
        Http.post(url)
        |> Http.stringBody(Json.stringify(encodedSignedTransaction))
        |> Http.send()

      json =
        Json.parse(response.body)
        |> Maybe.toResult("Json parsing error for send transaction to blockchain")

      responseStatus =
        decode json as Axentro.Api.ResponseStatus

      if (responseStatus.status == "success") {
        successCallback(response.body)
      } else {
        try {
          errorResponse =
            decode json as Axentro.Api.Error

          failureCallback(errorResponse.reason)
        } catch Object.Error => error {
          failureCallback("Error decoding Api failure response")
        }
      }
    } catch Http.ErrorResponse => error {
      failureCallback("Error sending to url: " + error.url)
    } catch {
      failureCallback("Failed to create the transaction before sending")
    }
  }
}
