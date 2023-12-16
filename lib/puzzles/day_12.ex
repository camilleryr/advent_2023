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

  defp find(rem, :empty, [], state),
    do: if("#" in rem, do: state, else: %{state | count: state.count + 1})

  defp find([], :empty, [], state), do: %{state | count: state.count + 1}
  defp find([], 0, [], state), do: %{state | count: state.count + 1}

  defp find(["." | rest], :empty, groups, state), do: find(rest, :empty, groups, state)
  defp find(["." | rest], 0, groups, state), do: find(rest, :empty, groups, state)
  defp find(["." | _rest], _, _, state), do: state

  defp find(["#" | _rest], :empty, [], state), do: state
  defp find(["#" | rest], :empty, [next | groups], state), do: find(rest, next - 1, groups, state)
  defp find(["#" | _rest], 0, _, state), do: state
  defp find(["#" | rest], rem, groups, state), do: find(rest, rem - 1, groups, state)

  defp find(["?" | rest], rem, groups, state) do
    state1 = memo_find(["." | rest], rem, groups, state)
    state2 = memo_find(["#" | rest], rem, groups, %{state | memo: state1.memo})

    %{count: state1.count + state2.count, memo: state2.memo}
  end

  defp find(_, _, _, state), do: state

  defp memo_find(record, rem, groups, state) do
    key = hash({record, rem, groups})

    if Map.has_key?(state.memo, key) do
      %{state | count: state.count + Map.get(state.memo, key)}
    else
      record
      |> find(rem, groups, state)
      |> then(&update_memo(key, &1))
    end
  end

  defp update_memo(key, return) do
    %{return | memo: Map.put(return.memo, key, return.count)}
  end

  defp hash(val), do: :erlang.phash2(val, 1_000_000_000)

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
