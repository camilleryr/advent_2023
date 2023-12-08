defmodule Mix.Tasks.GenTimeTable do
  @moduledoc """
    `mix gen_time_table`
  """

  use Mix.Task

  @table_pattern ~r/\| (\d+) \| (\d+) \| (\d+) ms\|/


  @shortdoc "Generate a markdown table of execution times and add it to the READEME file"
  def run(opts) do
    Mix.env(:test)

    filter_fun =
      case opts do
        [] -> & &1
        days -> &(&1 in days)
      end

    header = """
    ****\n
    Advent Of Code 2023 Execution Times (in ms)\n
    Puzzles can be found [here](https://adventofcode.com/2023/)\n
    ----

    | Day | Part | Execution Time |
    | --- | ---- | -------------- |
    """

    existing_times =
      File.read!("./README.md")
      |> String.split("\n")
      |> Enum.flat_map(fn line ->
        case Regex.scan(@table_pattern, line)  do
          [[_ | [_day, _part, _ms] = numbers]] ->
            numbers |> Enum.map(&String.to_integer/1) |> List.to_tuple() |> List.wrap()

            _ -> []
        end
    end)
      |> Enum.reject(fn {day, _, _} -> filter_fun.(to_string(day)) end)

    times =
      File.cwd!()
      |> Path.join("/lib/puzzles")
      |> File.ls!()
      |> Enum.map(&String.replace(&1, ~r/[a-z._]/, ""))
      |> Enum.filter(&filter_fun.(&1))
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
      |> Enum.flat_map(fn day ->
        for part <- [1, 2] do
          {time, _res} = :timer.tc(fn -> Advent2023.solve(day, part) end)
          {day, part, System.convert_time_unit(time, :microsecond, :millisecond)}
        end
      end)
      |> Enum.concat(existing_times)
      |> Enum.sort()

    table_body =
      times
      |> Enum.map(fn {day, part, time} -> "| #{day} | #{part} | #{time} ms|" end)
      |> Enum.join("\n")

    total_time =
      times
      |> Enum.map(&elem(&1, 2))
      |> Enum.sum()
      |> then(fn total ->
        "\n||total|#{total} ms|"
      end)

    File.write!("./README.md", header <> table_body <> total_time)
  end
end
