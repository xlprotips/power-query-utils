(values as list) as list =>
  let
    RT = List.Generate(
      () => [RT = values{0}, counter = 0],
      each [counter] < List.Count(values),
      each [RT = [RT] + values{[counter] + 1}, counter = [counter] + 1],
      each [RT]
    )
  in
    RT
