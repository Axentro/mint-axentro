suite "JsonUtil.encodeTransaction" {
  test "should encode transaction according to encoding rules" {
    try {
      senders =
        [
          ScaledSender("VDAyNThiOWFiN2Q5YWM3ZjUyYTNhYzQwZTY1NDBmYWJkMjczZmVmZThlOTgzMWM4", "8b3c61787fb6b07bb20e4a908deca52ef96335e4faaaaca18a227f9d674dcc57", 2000, 1000, "0"),
          ScaledSender("VDBiYjkyMjY1ZDJlOTNkZmNjN2NmYWFhZTVhMzVlYjZmYjY2YzllNWFjYWY3N2Nh", "cd79aa3b76078fb6dbe8199fccbc49a7e0deadbc9370791180e34dbabd65a47e", 5000, 1000, "0")
        ]

      recipients =
        [
          ScaledRecipient("VDAwZDRiYTg0MWVlZjE4M2U3OWY2N2E0YmZkZDJjN2JmMWE0ZTViMjE3ZDNmZTU1", 3000),
          ScaledRecipient("VDA4M2YwYTkzZTQxZTQ0NzdjOGRjMDU4ZTkwZTI4OWY1NDNkMDZjYmU3ODQyM2Rk", 2000)
        ]

      transaction =
        ScaledTransaction("be8473ea093084461006581b776c2ef1b960ee946a5eaf42f175cd9aace8fd1a", "send", senders, recipients, "0", "AXNT", "0", 1615927723068, 1, "FAST", "V1")

      json =
        JsonUtil.encodeTransaction(transaction)

      expectedJson =
        "{\"id\":\"be8473ea093084461006581b776c2ef1b960ee946a5eaf42f175cd9aace8fd1a\",\"action\":\"send\",\"message\":\"0\",\"token\":\"AXNT\",\"prev_hash\":\"0\",\"timestamp\":1615927723068,\"scaled\":1,\"kind\":\"FAST\",\"version\":\"V1\",\"senders\":[{\"address\":\"VDAyNThiOWFiN2Q5YWM3ZjUyYTNhYzQwZTY1NDBmYWJkMjczZmVmZThlOTgzMWM4\",\"public_key\":\"8b3c61787fb6b07bb20e4a908deca52ef96335e4faaaaca18a227f9d674dcc57\",\"amount\":2000,\"fee\":1000,\"signature\":\"0\"},{\"address\":\"VDBiYjkyMjY1ZDJlOTNkZmNjN2NmYWFhZTVhMzVlYjZmYjY2YzllNWFjYWY3N2Nh\",\"public_key\":\"cd79aa3b76078fb6dbe8199fccbc49a7e0deadbc9370791180e34dbabd65a47e\",\"amount\":5000,\"fee\":1000,\"signature\":\"0\"}],\"recipients\":[{\"address\":\"VDA4M2YwYTkzZTQxZTQ0NzdjOGRjMDU4ZTkwZTI4OWY1NDNkMDZjYmU3ODQyM2Rk\",\"amount\":2000},{\"address\":\"VDAwZDRiYTg0MWVlZjE4M2U3OWY2N2E0YmZkZDJjN2JmMWE0ZTViMjE3ZDNmZTU1\",\"amount\":3000}]}"

      (json == expectedJson)
    }
  }
}
