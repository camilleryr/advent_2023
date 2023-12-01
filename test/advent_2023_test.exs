defmodule Advent2023Test do
  use ExUnit.Case

  File.cwd!()
  |> Path.join("/lib/puzzles")
  |> File.ls!()
  |> Enum.map(&String.replace(&1, ".ex", ""))
  |> Enum.map(fn day ->
    num = String.replace(day, "day_", "")
    module = Module.concat(["Day#{num}"])
    tag = String.to_atom(day)

    only =
      Application.compile_env(:ex_unit, :include, [])
      |> Enum.filter(fn atom -> atom |> to_string() |> String.contains?("part") end)
      |> Enum.map(fn part -> {part, 1} end)
      |> case do
        [] -> []
        list -> [only: list]
      end

    except =
      Application.compile_env(:ex_unit, :exclude, [])
      |> Enum.filter(fn atom -> atom |> to_string() |> String.contains?("part") end)
      |> Enum.map(fn part -> {part, 1} end)
      |> case do
        [] -> []
        list -> [except: list]
      end

    doctest(module, Enum.concat([import: true, tags: [tag]], only ++ except))
  end)
end
