suite "Result.flatMap" {
  test "flat maps over the Ok Result" {
    (Result.ok("TEST")
    |> Result.Extra.flatMap(\r : String => Result.ok(r))
    |> Result.map(String.toLowerCase)
    |> Result.withDefault("")) == "test"
  }

  test "flat maps over the Err Result" {
    Result.ok("TEST")
    |> Result.Extra.flatMap(\r : String => Result.error(r))
    |> Result.isError()
  }
}

suite "Result.join" {
  test "flattens nested Results" {
    (Result.ok(Result.ok("TEST"))
    |> Result.Extra.join()
    |> Result.map(String.toLowerCase)
    |> Result.withDefault("")) == "test"
  }

  test "flattens nested Results when Err" {
    Result.ok(Result.error("Error"))
    |> Result.Extra.join()
    |> Result.isError()
  }
}
