module Result.Extra {
  fun join (input : Result(x, Result(x, value))) : Result(x, value) {
    case (input) {
      Result::Ok value => value
      Result::Err => input
    }
  }

  fun flatMap (
    func : Function(a, Result(x, b)),
    input : Result(x, a)
  ) : Result(x, b) {
    input
    |> Result.map(func)
    |> Result.Extra.join()
  }
}
