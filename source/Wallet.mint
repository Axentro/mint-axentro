enum KeyPair.Error {
  KeyPairGenerationError
}

enum Wallet.Error {
  InvalidNetwork
  WalletGenerationError
  EncryptWalletError
  DecryptWalletError
  FromWifWalletError
  SigningError
  InvalidAddressError
  AddressLengthError
  MnemonicGenerationError
}

record KeyPair {
  hexPrivateKey : String,
  hexPublicKey : String
}

record Wallet {
  publicKey : String using "public_key",
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

record Sender {
  address : String,
  publicKey : String using "public_key",
  amount : String,
  fee : String,
  signr : String using "sign_r",
  signs : String using "sign_s"
}

record Recipient {
  address : String,
  amount : String
}

record Transaction {
  id : String,
  action : String,
  senders : Array(Sender),
  recipients : Array(Recipient),
  message : String,
  token : String,
  prevHash : String using "prev_hash",
  timestamp : Number,
  scaled : Number
}

module Sushi.Wallet {
  fun generateKeyPair : Result(KeyPair.Error, KeyPair) {
    `
    (() => {
      try {
        return #{Result::Ok(`new Record(generateValidKeyPair())`)}
      } catch (e) {
        return #{Result::Err(KeyPair.Error::KeyPairGenerationError)}
      }
    })()
    `
  }

  fun generateNewWallet (networkPrefix : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        if (["T0", "M0"].indexOf(#{networkPrefix}) === -1) {
          return new Err(#{Wallet.Error::InvalidNetwork})
        }

        var keyPair = generateValidKeyPair();

        var wallet = {
          publicKey: keyPair.hexPublicKey,
          wif: makeWif(keyPair.hexPrivateKey, #{networkPrefix}),
          address: makeAddress(keyPair.hexPublicKey, #{networkPrefix})
        }

        return #{Result::Ok(`new Record(wallet)`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::WalletGenerationError)}
      }
    })()
    `
  }

  fun generateEncryptedWallet (networkPrefix : String, password : String) : Result(Wallet.Error, EncryptedWallet) {
    Sushi.Wallet.generateNewWallet(networkPrefix)
    |> Result.flatMap(
      (w : Wallet) : Result(Wallet.Error, EncryptedWallet) { Sushi.Wallet.encryptWallet(w, password) })
  }

  fun encryptWallet (wallet : Wallet, password : String) : Result(Wallet.Error, EncryptedWallet) {
    `
    (() => {
      try {
        var address = #{wallet}.address;
        var salt = all_crypto.bcrypt.genSaltSync(10)
        var hash = all_crypto.bcrypt.hashSync(#{password}, salt)

        var walletJson = JSON.stringify(#{wallet});
        var bf = new all_crypto.blowfish(reverseString(hash));
        var ciphertext = ab2hexstring(bf.encode(walletJson));

        var encryptedWallet = {
               source: "kajiki",
               ciphertext: ciphertext,
               address: address,
               salt: salt
        };

        return #{Result::Ok(`new Record(encryptedWallet)`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::EncryptWalletError)}
      }
    })()
    `
  }

  fun decryptWallet (encryptedWallet : EncryptedWallet, password : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        var hash = all_crypto.bcrypt.hashSync(#{password}, #{encryptedWallet}.salt)
        var bf = new all_crypto.blowfish(reverseString(hash));
        var binaryCipherText = new Uint8Array(hexstring2ab(#{encryptedWallet}.ciphertext));
        var wallet = JSON.parse(bf.decode(binaryCipherText));

        return #{Result::Ok(`new Record(wallet)`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::DecryptWalletError)}
      }
    })()
    `
  }

  fun getWalletFromWif (wif : String) : Result(Wallet.Error, Wallet) {
    `
    (() => {
      try {
        var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(#{wif});
        var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
        var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);

        var wallet = {
            publicKey: publicKey,
            wif: #{wif},
            address: address
        }
        return #{Result::Ok(`new Record(wallet)`)}
      } catch (e) {
        return  #{Result::Err(Wallet.Error::FromWifWalletError)}
      }
    })()
    `
  }

  fun getFullWalletFromWif (wif : String) : Result(Wallet.Error, FullWallet) {
    `
    (() => {
      try {
        var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(#{wif});
        var privateKey = privateKeyNetwork.privateKey;
        var network = privateKeyNetwork.network;
        var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
        var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);

        var wallet = {
            network: new Record(network),
            privateKey: privateKey,
            publicKey: publicKey,
            wif: #{wif},
            address: address
        }
        return #{Result::Ok(`new Record(wallet)`)}
      } catch (e) {
        return  #{Result::Err(Wallet.Error::FromWifWalletError)}
      }
    })()
    `
  }

  fun signTransaction (hexPrivateKey : String, transaction : Transaction) : Result(Wallet.Error, Transaction) {
    `
    (() => {
      try {
        var transactionJson = JSON.stringify(#{transaction})
        var transaction_hash = all_crypto.cryptojs.SHA256(transactionJson).toString();

        var sign_sender = function(sender){
          var privateKeyBinary = new all_crypto.BigInteger.fromHex(#{hexPrivateKey});
          var signed = sign(privateKeyBinary, transaction_hash);
          var sign_r = signed[0].toString(16);
          var sign_s = signed[1].toString(16);

          var signed_sender = sender
          signed_sender.signr = sign_r
          signed_sender.signs = sign_s

          return new Record(signed_sender)
        }

        var signed_senders = #{transaction}.senders.map(sign_sender)
        var signed_transaction = #{transaction}
        signed_transaction.senders = signed_senders

        return #{Result::Ok(`new Record(signed_transaction)`)}
      } catch (e) {
        return  #{Result::Err(Wallet.Error::SigningError)}
      }
    })()
    `
  }

  fun verifyTransaction (
    hexPublicKey : String,
    message : String,
    r : String,
    s : String
  ) : Result(Wallet.Error, Bool) {
    `
    (() => {
      try {
        return #{Result::Ok(`verify(hexPublicKey, message, r, s)`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::SigningError)}
      }
    })()
    `
  }

  fun isValidAddress (address : String) : Result(Wallet.Error, Bool) {
    `
    (() => {
      try {
        var decodedAddress = all_crypto.base64.Base64.decode(#{address});

        if (decodedAddress.length !== 48) {
            new Err(#{Wallet.Error::AddressLengthError})
        }

        var versionAddress = decodedAddress.substring(0, decodedAddress.length - 6);
        var hashedAddress = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(versionAddress).toString()).toString();
        var checksum = decodedAddress.substring(decodedAddress.length - 6, decodedAddress.length);
        var res = checksum === hashedAddress.substring(0, 6);

        return #{Result::Ok(`res`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::InvalidAddressError)}
      }
    })()
    `
  }

  fun getMnemonic (hexPrivateKey : String) : Result(Wallet.Error, Array(String)) {
    `
    (() => {
      try {
        var words = all_crypto.mnemonic.fromHex(#{hexPrivateKey}).toWords()
        return #{Result::Ok(`words`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::MnemonicGenerationError)}
      }
    })()
    `
  }

  fun getKeyFromMnemonic (words : Array(String)) : Result(Wallet.Error, String) {
    `
    (() => {
      try {
        var pk = all_crypto.mnemonic.fromWords(#{words}).toHex()
        return #{Result::Ok(`pk`)}
      } catch (e) {
        return #{Result::Err(Wallet.Error::MnemonicGenerationError)}
      }
    })()
    `
  }
}
