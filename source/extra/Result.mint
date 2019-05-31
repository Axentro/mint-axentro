module Result.Extra {
  fun join (input : Result(x, Result(x, value))) : Result(x, value) {
    if (Result.isOk(input)) {
      `#{input}.value`
    } else {
      `new Err()`
    }
  }

  fun flatMap (
    func : Function(a, Result(x, b)),
    input : Result(x, a)
  ) : Result(x, b) {
    Result.map(func, input)
    |> Result.Extra.join()
  }
}
