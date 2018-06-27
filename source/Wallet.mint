enum KeyPair.Error {
  KeyPairGenerationError
}

enum Wallet.Error {
  InvalidNetwork,
  WalletGenerationError
}

record KeyPair {
  hexPrivateKey : String,
  hexPublicKey : String,
  hexPublicKeyX : String,
  hexPublicKeyY : String
}

record Wallet {
  publicKey : String,
  wif : String,
  address : String
}

module Network {
  fun testNet : String {
    "T0"
  }

  fun mainNet : String {
    "M0"
  }
}

module Sushi.Wallet {
  fun generateKeyPair : Result(KeyPair.Error, KeyPair) {
    `
    (() => {
      try {
        return new Ok(generateValidKeyPair())
      } catch (e) {
        return new Err($KeyPair_Error_KeyPairGenerationError)
      }
    })()
    `
  }

  fun generateNewWallet (networkPrefix : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        if (["T0", "M0"].indexOf(networkPrefix) === -1) {
          return new Err($Wallet_Error_InvalidNetwork)
        }

        var keyPair = generateValidKeyPair();

        var result = {
          publicKey: keyPair.hexPublicKey,
          wif: makeWif(keyPair.hexPrivateKey, networkPrefix),
          address: makeAddress(keyPair.hexPublicKey, networkPrefix)
        }

        return new Ok(result)
      } catch (e) {
        return new Err($Wallet_Error_WalletGenerationError)
      }
    })()
    `
  }
}
