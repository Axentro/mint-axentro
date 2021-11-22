suite "Wallet.getMnemonic" {
  test "should generate 24 words from hexPrivateKey" {
    try {
      privateKey =
        "a7e9ed17f470fac90f9699d3302a9fb77aa5f94f04424b3c7071b7c1" \
        "d8ab21d9"

      expectedWords =
        [
          "tune",
          "begin",
          "throughout",
          "shown",
          "look",
          "belly",
          "large",
          "clean",
          "neck",
          "idea",
          "generation",
          "warm",
          "crime",
          "generation",
          "grace",
          "sigh",
          "image",
          "gentle",
          "focus",
          "become",
          "presence",
          "earth",
          "god",
          "glorious"
        ]

      words =
        Axentro.Wallet.getMnemonic(privateKey)

      (expectedWords == words)
    } catch Wallet.Error => error {
      false
    }
  }
}

suite "Wallet.getKeyFromMnemonic" {
  test "should get hexPrivateKey from words" {
    try {
      expectedPrivateKey =
        "a7e9ed17f470fac90f9699d3302a9fb77aa5f94f04424b3c7071b7c1" \
        "d8ab21d9"

      words =
        [
          "tune",
          "begin",
          "throughout",
          "shown",
          "look",
          "belly",
          "large",
          "clean",
          "neck",
          "idea",
          "generation",
          "warm",
          "crime",
          "generation",
          "grace",
          "sigh",
          "image",
          "gentle",
          "focus",
          "become",
          "presence",
          "earth",
          "god",
          "glorious"
        ]

      privateKey =
        Axentro.Wallet.getKeyFromMnemonic(words)

      (expectedPrivateKey == privateKey)
    } catch Wallet.Error => error {
      false
    }
  }
}

suite "Wallet.getReEncryptedWalletFromMnemonic" {
  test "should get wif from private key" {
     try {
       networkPrefix = Network.Prefix.testNet()

       wallet =
          Axentro.Wallet.generateNewWallet(networkPrefix)
      
       privateKey =
          Axentro.Wallet.getPrivateKeyFromWif(wallet.wif)

       wif = Axentro.Wallet.getWifFromPrivateKey(privateKey, networkPrefix)     
        
      (wif == wallet.wif)
    } catch Wallet.Error => error {
      false
    }
  }
  test "should get re-encrypted wallet from words" {
    try {
      password = "password"

      networkPrefix = Network.Prefix.testNet()
      
      wallet =
        Axentro.Wallet.generateNewWallet(networkPrefix)
      
      privateKey =
        Axentro.Wallet.getPrivateKeyFromWif(wallet.wif)

      words =
        Axentro.Wallet.getMnemonic(privateKey)

      encrypted =
        Axentro.Wallet.getReEncryptedWalletFromMnemonic("name", networkPrefix, words, password)

      decrypted =
        Axentro.Wallet.decryptWallet(encrypted, password)

      (wallet == decrypted)

    } catch Wallet.Error => error {
      false
    }
  }
}
