enum Transactions.Error {
  IdGenerationError
  ScalingError
}

record Sender {
  address : String,
  publicKey : String using "public_key",
  amount : String,
  fee : String,
  signature : String
}

record Recipient {
  address : String,
  amount : String
}

record Asset {
  assetId : String using "asset_id",
  name : String,
  description : String,
  mediaLocation : String using "media_location",
  mediaHash : String using "media_hash",
  quantity : Number,
  terms : String,
  locked : String,
  version : Number,
  timestamp : Number
}

record Module {
  moduleId : String using "module_id",
  timestamp : Number
}

record Input {
  inputId : String using "input_id",
  timestamp : Number
}

record Output {
  outputId : String using "output_id",
  timestamp : Number
}

record Transaction {
  id : String,
  action : String,
  senders : Array(Sender),
  recipients : Array(Recipient),
  assets : Array(Asset),
  modules : Array(Module),
  inputs : Array(Input),
  outputs : Array(Output),
  linked : String,
  message : String,
  token : String,
  prevHash : String using "prev_hash",
  timestamp : Number,
  scaled : Number,
  kind : String,
  version : String
}

record ScaledSender {
  address : String,
  publicKey : String using "public_key",
  amount : Number,
  fee : Number,
  signature : String
}

record ScaledRecipient {
  address : String,
  amount : Number
}

record ScaledTransaction {
  id : String,
  action : String,
  senders : Array(ScaledSender),
  recipients : Array(ScaledRecipient),
  assets : Array(Asset),
  modules : Array(Module),
  inputs : Array(Input),
  outputs : Array(Output),
  linked : String,
  message : String,
  token : String,
  prevHash : String using "prev_hash",
  timestamp : Number,
  scaled : Number,
  kind : String,
  version : String
}

module Axentro.Transactions {
  fun generateId : Result(Transactions.Error, String) {
    `
    (() => {
      try {
        var id = toHexString(all_crypto.secureRandom(32));
        return #{Result::Ok(`id`)}
      } catch (e) {
        return #{Result::Err(Transactions.Error::IdGenerationError)}
      }
    })()
    `
  }

  fun timestamp : Number {
    `new Date().valueOf()`
  }

  fun toUnscaledAmount (value : Number) : Result(Transactions.Error, String) {
    `
    (() => {
      try {
        var amount = new all_crypto.decimaljs(#{value} / 100000000).toString();
        return #{Result::Ok(`amount`)}
      } catch (e) {
        return #{Result::Err(Transactions.Error::ScalingError)}
      }
    })()
    `
  }

  fun toScaledAmount (value : String) : Result(Transactions.Error, Number) {
    `
    (() => {
      try {
        var amount = (new all_crypto.decimaljs(#{value}) * 100000000);
        return #{Result::Ok(`amount`)}
      } catch (e) {
        return #{Result::Err(Transactions.Error::ScalingError)}
      }
    })()
    `
  }

  fun toScaledTransaction (transaction : Transaction) : ScaledTransaction {
    {
      id = transaction.id,
      action = transaction.action,
      senders = toScaledSenders(transaction.senders),
      recipients = toScaledRecipients(transaction.recipients),
      assets = transaction.assets,
      modules = transaction.modules,
      inputs = transaction.inputs,
      outputs = transaction.outputs,
      linked = transaction.linked,
      message = transaction.message,
      token = transaction.token,
      prevHash = transaction.prevHash,
      timestamp = transaction.timestamp,
      scaled = 1,
      kind = transaction.kind,
      version = transaction.version
    }
  }

  fun toUnscaledTransaction (transaction : ScaledTransaction) : Transaction {
    {
      id = transaction.id,
      action = transaction.action,
      senders = toUnscaledSenders(transaction.senders),
      recipients = toUnscaledRecipients(transaction.recipients),
      assets = transaction.assets,
      modules = transaction.modules,
      inputs = transaction.inputs,
      outputs = transaction.outputs,
      linked = transaction.linked,
      message = transaction.message,
      token = transaction.token,
      prevHash = transaction.prevHash,
      timestamp = transaction.timestamp,
      scaled = 0,
      kind = transaction.kind,
      version = transaction.version
    }
  }

  fun toScaledSenders (senders : Array(Sender)) : Array(ScaledSender) {
    senders
    |> Array.map(
      (sender : Sender) {
        try {
          scaledAmount =
            toScaledAmount(sender.amount)

          scaledFee =
            toScaledAmount(sender.fee)

          {
            address = sender.address,
            publicKey = sender.publicKey,
            amount = scaledAmount,
            fee = scaledFee,
            signature = sender.signature
          }
        } catch Transactions.Error => error {
          try {
            Debug.log("error scaling senders")

            {
              address = sender.address,
              publicKey = sender.publicKey,
              amount = 0,
              fee = 0,
              signature = sender.signature
            }
          }
        }
      })
  }

  fun toScaledRecipients (recipients : Array(Recipient)) : Array(ScaledRecipient) {
    recipients
    |> Array.map(
      (recipient : Recipient) {
        try {
          scaledAmount =
            toScaledAmount(recipient.amount)

          {
            address = recipient.address,
            amount = scaledAmount
          }
        } catch Transactions.Error => error {
          try {
            Debug.log("error scaling recipients")

            {
              address = recipient.address,
              amount = 0
            }
          }
        }
      })
  }

  fun toUnscaledSenders (senders : Array(ScaledSender)) : Array(Sender) {
    senders
    |> Array.map(
      (sender : ScaledSender) {
        try {
          unscaledAmount =
            toUnscaledAmount(sender.amount)

          unscaledFee =
            toUnscaledAmount(sender.fee)

          {
            address = sender.address,
            publicKey = sender.publicKey,
            amount = unscaledAmount,
            fee = unscaledFee,
            signature = sender.signature
          }
        } catch Transactions.Error => error {
          try {
            Debug.log("error unscaling senders")

            {
              address = sender.address,
              publicKey = sender.publicKey,
              amount = "0",
              fee = "0",
              signature = sender.signature
            }
          }
        }
      })
  }

  fun toUnscaledRecipients (recipients : Array(ScaledRecipient)) : Array(Recipient) {
    recipients
    |> Array.map(
      (recipient : ScaledRecipient) {
        try {
          unscaledAmount =
            toUnscaledAmount(recipient.amount)

          {
            address = recipient.address,
            amount = unscaledAmount
          }
        } catch Transactions.Error => error {
          try {
            Debug.log("error unscaling recipients")

            {
              address = recipient.address,
              amount = "0"
            }
          }
        }
      })
  }

  fun createSendAxntScaledTransactionFromWallet (toAddress : String, amount : String, wallet : Wallet) : Result(Transactions.Error, ScaledTransaction) {
    try {
      fromAddress =
        wallet.address

      fromPublicKey =
        wallet.publicKey

      createSendAxntScaledTransaction(fromAddress, fromPublicKey, toAddress, amount)
    }
  }

  fun createSendAxntScaledTransaction (
    fromAddress : String,
    fromPublicKey : String,
    toAddress : String,
    amount : String
  ) : Result(Transactions.Error, ScaledTransaction) {
    createSendAmountScaledTransaction(fromAddress, fromPublicKey, toAddress, amount, "AXNT", "0.0001")
  }

  fun createSendAmountScaledTransaction (
    fromAddress : String,
    fromPublicKey : String,
    toAddress : String,
    amount : String,
    token : String,
    fee : String
  ) : Result(Transactions.Error, ScaledTransaction) {
    try {
      id =
        generateId()

      scaledAmount =
        toScaledAmount(amount)

      scaledFee =
        toScaledAmount(fee)

      senders =
        [
          {
            address = fromAddress,
            publicKey = fromPublicKey,
            amount = scaledAmount,
            fee = scaledFee,
            signature = "0"
          }
        ]

      recipients =
        [
          {
            address = toAddress,
            amount = scaledAmount
          }
        ]

      transaction =
        {
          id = id,
          action = "send",
          senders = senders,
          recipients = recipients,
          assets = [],
          modules = [],
          inputs = [],
          outputs = [],
          linked = "",
          message = "",
          token = token,
          prevHash = "0",
          timestamp = timestamp(),
          scaled = 1,
          kind = "FAST",
          version = "V1"
        }

      Result::Ok(transaction)
    } catch Transactions.Error => error {
      Result::Err(error)
    }
  }
}
