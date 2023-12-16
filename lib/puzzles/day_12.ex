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
    |> Enum.map(&find_possible_solutions/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    525152
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Enum.map(&parse_line/1)
    |> Enum.map(&unfold_line/1)
    |> Enum.map(&find_possible_solutions/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> find_possible_solutions({["?", "?", "?", ".", "#", "#", "#"], [1, 1, 3]})
    1
  """
  def find_possible_solutions({record, groups}) do
    record
    |> find(:empty, groups, %{count: 0, memo: %{}})
    |> Map.get(:count)
  end

  defp find([], :empty, [], state), do: Map.update!(state, :count, &(&1 + 1))
  defp find([], 0, [], state), do: Map.update!(state, :count, &(&1 + 1))

  defp find(["." | rest], :empty, groups, state), do: find(rest, :empty, groups, state)
  defp find(["." | rest], 0, groups, state), do: find(rest, :empty, groups, state)
  defp find(["." | _rest], _, _, state), do: state

  defp find(["#" | rest], :empty, [], state), do: state
  defp find(["#" | rest], :empty, [next | groups], state), do: find(rest, next - 1, groups, state)
  defp find(["#" | _rest], 0, _, state), do: state
  defp find(["#" | rest], rem, groups, state), do: find(rest, rem - 1, groups, state)

  defp find(["?" | rest], rem, groups, state) do
    state1 = memo_find(["." | rest], rem, groups, state)
    state2 = memo_find(["#" | rest], rem, groups, %{state | memo: state1.memo})

    %{count: state1.count + state2.count, memo: Map.merge(state1.memo, state2.memo)}
  end

  defp find(_, _, _, state), do: state

  defp memo_find(record, rem, groups, state) do
    case Map.get(state.memo, {record, rem, groups}) do
      nil ->
        record
        |> find(rem, groups, state)
        |> then(fn ret ->
          Map.update!(ret, :memo, &Map.put(&1, {record, rem, groups}, ret.count))
        end)

      count ->
        Map.update!(state, :count, &(&1 + count))
    end
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

  def parse_line(line) do
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
