enum KeyPair.Error {
  KeyPairGenerationError
}

enum Wallet.Error {
  InvalidNetwork,
  WalletGenerationError,
  EncryptWalletError,
  DecryptWalletError,
  FromWifWalletError
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

record FullWallet {
  network : Network,
  privateKey : String,
  publicKey : String,
  wif : String,
  address : String
}

record EncryptedWallet {
  source : String,
  ciphertext : String,
  address : String,
  salt : String
}

module Sushi.Wallet {
  fun generateKeyPair : Result(KeyPair.Error, KeyPair) {
    `
    (() => {
      try {
        return new Ok(new Record(generateValidKeyPair()))
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

        var wallet = {
          publicKey: keyPair.hexPublicKey,
          wif: makeWif(keyPair.hexPrivateKey, networkPrefix),
          address: makeAddress(keyPair.hexPublicKey, networkPrefix)
        }

        return new Ok(new Record(wallet))
      } catch (e) {
        return new Err($Wallet_Error_WalletGenerationError)
      }
    })()
    `
  }

  fun encryptWallet (wallet : Wallet, password : String) : Result(Wallet.Error, EncryptedWallet) {
    `
    (() => {
      try {
        var address = wallet.address;
        var salt = all_crypto.bcrypt.genSaltSync(10)
        var hash = all_crypto.bcrypt.hashSync(password, salt)

        var walletJson = JSON.stringify(wallet);
        var bf = new all_crypto.blowfish(reverseString(hash));
        var ciphertext = ab2hexstring(bf.encode(walletJson));

        var encryptedWallet = {
               source: "kajiki",
               ciphertext: ciphertext,
               address: address,
               salt: salt
        };

        return new Ok(new Record(encryptedWallet))
      } catch (e) {
        return new Err($Wallet_Error_EncryptWalletError)
      }
    })()
    `
  }

  fun decryptWallet (encryptedWallet : EncryptedWallet, password : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        var hash = all_crypto.bcrypt.hashSync(password, encryptedWallet.salt)
        var bf = new all_crypto.blowfish(reverseString(hash));
        var binaryCipherText = new Uint8Array(hexstring2ab(encryptedWallet.ciphertext));
        var wallet = JSON.parse(bf.decode(binaryCipherText));

        return new Ok(new Record(wallet))
      } catch (e) {
        return new Err($Wallet_Error_DecryptWalletError)
      }
    })()
    `
  }

  fun getWalletFromWif (wif : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(wif);
        var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
        var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);

        var wallet = {
            publicKey: publicKey,
            wif: wif,
            address: address
        }
        return new Ok(new Record(wallet))
      } catch (e) {
        return new Err($Wallet_Error_FromWifWalletError)
      }
    })()
    `
  }

  fun getFullWalletFromWif (wif : String) : Result(Wallet.Error, FullWallet) {
    `
    (() => {
      try {
        var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(wif);
        var privateKey = privateKeyNetwork.privateKey;
        var network = privateKeyNetwork.network;
        var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
        var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);

        var wallet = {
            network: new Record(network),
            privateKey: privateKey,
            publicKey: publicKey,
            wif: wif,
            address: address
        }
        return new Ok(new Record(wallet))
      } catch (e) {
        return new Err($Wallet_Error_FromWifWalletError)
      }
    })()
    `
  }
}
