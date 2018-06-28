record Network {
  prefix : String,
  name : String
}

module Network.Prefix {
  fun testNet : String {
    "T0"
  }

  fun mainNet : String {
    "M0"
  }
}

module Network.Kind {
  fun testNet : Network {
    {
      prefix = Network.Prefix.testNet(),
      name = "testnet"
    }
  }

  fun mainNet : Network {
    {
      prefix = Network.Prefix.mainNet(),
      name = "mainnet"
    }
  }
}
