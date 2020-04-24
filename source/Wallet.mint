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
  salt : String,
  name : String
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

record Transaction {
  id : String,
  action : String,
  senders : Array(Sender),
  recipients : Array(Recipient),
  message : String,
  token : String,
  prevHash : String using "prev_hash",
  timestamp : Number,
  scaled : Number,
  kind : String
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
  message : String,
  token : String,
  prevHash : String using "prev_hash",
  timestamp : Number,
  scaled : Number,
  kind : String
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

  fun generateEncryptedWallet (
    networkPrefix : String,
    name : String,
    password : String
  ) : Result(Wallet.Error, EncryptedWallet) {
    Sushi.Wallet.generateNewWallet(networkPrefix)
    |> Result.flatMap(
      (w : Wallet) : Result(Wallet.Error, EncryptedWallet) { Sushi.Wallet.encryptWallet(w, name, password) })
  }

  fun encryptWallet (wallet : Wallet, name : String, password : String) : Result(Wallet.Error, EncryptedWallet) {
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
               salt: salt,
               name: #{name}
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

  fun getPrivateKeyFromWif (wif : String) : Result(Wallet.Error, String) {
    `
    (() => {
      try {
        var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(#{wif});
        var privateKey = privateKeyNetwork.privateKey;  
        return #{Result::Ok(`privateKey`)}
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

  fun signTransaction (
    hexPrivateKey : String,
    transaction : ScaledTransaction
  ) : Result(Wallet.Error, ScaledTransaction) {
    `
    (() => {
      try {
        var transaction_hash = all_crypto.cryptojs.SHA256(#{transactionJson}).toString();

        var sign_sender = function(sender){
          var signature = sign(#{hexPrivateKey}, transaction_hash);
        
          var signed_sender = sender
          signed_sender.signature = signature
        
          return signed_sender
        }

        var signed_senders = #{transaction}.senders.map(sign_sender)
        #{transaction}.senders = signed_senders

        console.log(signed_senders)

        return #{Result::Ok(transaction)}
      } catch (e) {
        console.log('OOOOPS sig');
        return  #{Result::Err(Wallet.Error::SigningError)}
      }
    })()
    `
  } where {
    transactionJson =
      Json.stringify(encode transaction)
  }

  fun verifyTransaction (
    hexPrivateKey : String,
    signedTransaction : ScaledTransaction
  ) : Result(Wallet.Error, Bool) {
    `
    (() => {
      try { 
        var unsign_sender = function(sender){
          var signed_sender = sender
          signed_sender.signature = '0'
          return signed_sender
        }

        var signatures = #{signedTransaction}.senders.map(function(sender){ return sender.signature})[0];
        var signature = signatures[0];
        

        var unsigned_senders = #{signedTransaction}.senders.map(unsign_sender)
        #{signedTransaction}.senders = unsigned_senders
        var transaction_hash = all_crypto.cryptojs.SHA256(#{Json.stringify(encode signedTransaction)}).toString();
   
        var result = verify(#{hexPrivateKey}, transaction_hash, signature)

        return #{Result::Ok(`result`)}
      } catch (e) {
        console.log('OOOOPS ver');
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
