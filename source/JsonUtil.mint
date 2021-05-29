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
          Object.Encode.field("recipients", recipients),
          Object.Encode.field("assets", assets),
          Object.Encode.field("modules", modules),
          Object.Encode.field("inputs", inputs),
          Object.Encode.field("outputs", outputs),
          Object.Encode.field("linked", Object.Encode.string(t.linked))
        ]))
  } where {
    senders =
      Object.Encode.array(
        t.senders
        |> Array.sort(
          (a : ScaledSender, b : ScaledSender) : Number {
            `#{a.address}.localeCompare(#{b.address}) || #{a.publicKey}.localeCompare(#{b.publicKey}) || #{a.amount} - #{b.amount} || #{a.fee} - #{b.fee} || #{a.signature}.localseCompare(#{b.signature})`
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
        |> Array.sort((a : ScaledRecipient, b : ScaledRecipient) : Number { `#{a.address}.localeCompare(#{b.address}) || #{a.amount} - #{b.amount}` })
        |> Array.map(
          (s : ScaledRecipient) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("address", Object.Encode.string(s.address)),
                Object.Encode.field("amount", Object.Encode.number(s.amount))
              ])
          }))

    assets =
      Object.Encode.array(
        t.assets
        |> Array.sort((a : Asset, b : Asset) : Number { `#{a.timestamp}.localeCompare(#{b.timestamp}) || #{a.assetId} - #{b.assetId}` })
        |> Array.map(
          (a : Asset) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("asset_id", Object.Encode.string(a.assetId)),
                Object.Encode.field("name", Object.Encode.string(a.name)),
                Object.Encode.field("description", Object.Encode.string(a.description)),
                Object.Encode.field("media_location", Object.Encode.string(a.mediaLocation)),
                Object.Encode.field("media_hash", Object.Encode.string(a.mediaHash)),
                Object.Encode.field("quantity", Object.Encode.number(a.quantity)),
                Object.Encode.field("terms", Object.Encode.string(a.terms)),
                Object.Encode.field("locked", Object.Encode.string(a.locked)),
                Object.Encode.field("version", Object.Encode.number(a.version)),
                Object.Encode.field("timestamp", Object.Encode.number(a.timestamp))
              ])
          }))

    modules =
      Object.Encode.array(
        t.modules
        |> Array.sort((a : Module, b : Module) : Number { `#{a.timestamp}.localeCompare(#{b.timestamp}) || #{a.moduleId} - #{b.moduleId}` })
        |> Array.map(
          (a : Module) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("module_id", Object.Encode.string(a.moduleId)),
                Object.Encode.field("timestamp", Object.Encode.number(a.timestamp))
              ])
          }))

    outputs =
      Object.Encode.array(
        t.outputs
        |> Array.sort((a : Output, b : Output) : Number { `#{a.timestamp}.localeCompare(#{b.timestamp}) || #{a.outputId} - #{b.outputId}` })
        |> Array.map(
          (a : Output) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("output_id", Object.Encode.string(a.outputId)),
                Object.Encode.field("timestamp", Object.Encode.number(a.timestamp))
              ])
          }))

    inputs =
      Object.Encode.array(
        t.inputs
        |> Array.sort((a : Input, b : Input) : Number { `#{a.timestamp}.localeCompare(#{b.timestamp}) || #{a.inputId} - #{b.inputId}` })
        |> Array.map(
          (a : Input) : Object {
            Object.Encode.object(
              [
                Object.Encode.field("input_id", Object.Encode.string(a.inputId)),
                Object.Encode.field("timestamp", Object.Encode.number(a.timestamp))
              ])
          }))
  }
}
