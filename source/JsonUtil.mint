module JsonUtil {
  fun encodeTransaction (t : ScaledTransaction) : String {
    Json.stringify(
      Object.Encode.object(
        [
          Object.Encode.field("id", Object.Encode.string(t.id)),
          Object.Encode.field("action", Object.Encode.string(t.action)),
          Object.Encode.field("message", Object.Encode.string(t.message)),
          Object.Encode.field("token", Object.Encode.string(t.token)),
          Object.Encode.field("prev_hash", Object.Encode.string(t.prevHash)),
          Object.Encode.field("timestamp", Object.Encode.number(t.timestamp)),
          Object.Encode.field("scaled", Object.Encode.number(t.scaled)),
          Object.Encode.field("kind", Object.Encode.string(t.kind)),
          Object.Encode.field("version", Object.Encode.string(t.version)),
          Object.Encode.field("senders", senders),
          Object.Encode.field("recipients", recipients)
        ]))
  } where {
    senders =
      Object.Encode.array(
        t.senders
        |> Array.sort(
          (a : ScaledSender, b : ScaledSender) : Number {
            `#{a.address} - #{b.address} - #{a.publicKey} - #{b.publicKey} - #{a.amount} - #{b.amount} - #{a.fee} - #{b.fee} - #{a.signature} - #{b.signature}`
          })
        |> Array.map(
          (s : ScaledSender) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("address", Object.Encode.string(s.address)),
                Object.Encode.field("public_key", Object.Encode.string(s.publicKey)),
                Object.Encode.field("amount", Object.Encode.number(s.amount)),
                Object.Encode.field("fee", Object.Encode.number(s.fee)),
                Object.Encode.field("signature", Object.Encode.string(s.signature))
              ])
          }))

    recipients =
      Object.Encode.array(
        t.recipients
        |> Array.sort((a : ScaledRecipient, b : ScaledRecipient) : Number { `#{a.address} - #{b.address} - #{a.amount} - #{b.amount}` })
        |> Array.map(
          (s : ScaledRecipient) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("address", Object.Encode.string(s.address)),
                Object.Encode.field("amount", Object.Encode.number(s.amount))
              ])
          }))
  }
}
