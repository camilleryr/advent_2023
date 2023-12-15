defmodule Day12 do
  @moduledoc "https://adventofcode.com/2023/day/12"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    21
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Enum.map(&parse_line/1)
    |> Task.async_stream(&find_possible_solutions/1)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    # iex> part_2(test_input(:part_1))
    # 525152
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Enum.map(&parse_line/1)
    |> Enum.map(&unfold_line/1)
    |> Task.async_stream(&find_possible_solutions/1, timeout: :infinity)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> find_possible_solutions({["?", "?", "?", ".", "#", "#", "#"], [1, 1, 3]})
    1
  """
  def find_possible_solutions({record, groups}) do
    record
    |> Enum.filter(&(&1 == "?"))
    |> expand_unkown([])
    |> Enum.map(&replace(record, &1))
    |> Enum.filter(fn replaced_record ->
      replaced_groups =
        replaced_record
        |> Enum.chunk_by(& &1)
        |> Enum.filter(fn [gear | _] -> gear == "#" end)
        |> Enum.map(&length/1)

      groups == replaced_groups
    end)
    |> Enum.count()
  end

  def replace(["?" | rest_record], [replacement | rest_replacements]),
    do: [replacement | replace(rest_record, rest_replacements)]

  def replace([head | rest_record], replacements), do: [head | replace(rest_record, replacements)]
  def replace([], []), do: []

  @doc ~S"""
  ## Example
    iex> expand_unkown(["?"], [])
    [["#"], [","]]

    iex> expand_unkown(["?", ?"], [])
    [["#", "#"], ["#", ","], [",", "#"], [",", ","]]
  """
  def expand_unkown([], acc), do: acc
  def expand_unkown([_ | rest], []), do: expand_unkown(rest, [["#"], [","]])

  def expand_unkown([_ | rest], acc) do
    new_acc =
      for x <- ["#", ","], existing <- acc do
        [x | existing]
      end

    expand_unkown(rest, new_acc)
  end

  @doc ~S"""
  ## Example
    iex> unfold_line({["?", "?", "?", ".", "#", "#", "#"], [1, 1, 3]})
    {~w|? ? ? . # # # ? ? ? ? . # # # ? ? ? ? . # # # ? ? ? ? . # # # ? ? ? ? . # # #|, [1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3]}
  """
  def unfold_line({record, groups}) do
    ["?" | new_record] = List.flatten(List.duplicate(["?" | record], 5))
    {new_record, List.flatten(List.duplicate(groups, 5))}
  end

  defp parse_line(line) do
    [record | groups] = String.split(line, [" ", ","])
    {String.graphemes(record), Enum.map(groups, &String.to_integer/1)}
  end

  def test_input(:part_1) do
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
  end
end
