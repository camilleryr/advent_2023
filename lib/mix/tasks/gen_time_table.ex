defmodule Mix.Tasks.GenTimeTable do
  @moduledoc """
    `mix gen_time_table`
  """

  use Mix.Task

  @shortdoc "Generate a markdown table of execution times and add it to the READEME file"
  def run(_) do
    Mix.env(:test)

    header = """
    ****\n
    Advent Of Code 2023 Execution Times (in ms)\n
    Puzzles can be found [here](https://adventofcode.com/2023/)\n
    ----

    | Day | Part | Execution Time |
    | --- | ---- | -------------- |
    """

    times =
      File.cwd!()
      |> Path.join("/lib/puzzles")
      |> File.ls!()
      |> Enum.map(&String.replace(&1, ~r/[a-z._]/, ""))
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> Enum.flat_map(fn day ->
        for part <- [1, 2] do
          {time, _res} = :timer.tc(fn -> Advent2023.solve(day, part) end)
          {day, part, time}
        end
      end)

    table_body =
      times
      |> Enum.map(fn {day, part, time} ->
        "| #{day} | #{part} | #{System.convert_time_unit(time, :microsecond, :millisecond)} ms|"
      end)
      |> Enum.join("\n")

    total_time =
      times
      |> Enum.map(&elem(&1, 2))
      |> Enum.sum()
      |> then(fn total ->
        "\n||total|#{System.convert_time_unit(total, :microsecond, :millisecond)} ms|"
      end)

    File.write!("./README.md", header <> table_body <> total_time)
  end
end
