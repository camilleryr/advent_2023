defmodule Day11 do
  @moduledoc "https://adventofcode.com/2023/day/11"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    374
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> expand_universe()
    |> find_shortest_distances()
    |> Enum.sum()
  end

  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> do_solve_part_2(1_000_000)
  end

  @doc ~S"""
  ## Example
    iex> test_input(:part_1) |> String.split("\n") |> parse() |> do_solve_part_2(10)
    1030

    iex> test_input(:part_1) |> String.split("\n") |> parse() |> do_solve_part_2(100)
    8410
  """
  def do_solve_part_2(map, factor) do
    map
    |> expand_universe(factor)
    |> find_shortest_distances()
    |> Enum.sum()
  end

  defp find_shortest_distances(map) when is_map(map) do
    map
    |> Map.keys()
    |> find_shortest_distances()
  end

  defp find_shortest_distances([head | [_ | _] = tail]) do
    tail
    |> Enum.map(&manhattan_distance(head, &1))
    |> Enum.concat(find_shortest_distances(tail))
  end

  defp find_shortest_distances([_]), do: []

  defp manhattan_distance({a_x, a_y}, {b_x, b_y}),
    do: max(a_x, b_x) - min(a_x, b_x) + (max(a_y, b_y) - min(a_y, b_y))

  defp expand_universe(universe, factor \\ 2) do
    universe
    |> expand_universe(factor, :x)
    |> expand_universe(factor, :y)
  end

  defp expand_universe(universe, factor, selector) do
    universe
    |> Enum.sort_by(fn {point, _} -> get_dimension(point, selector) end)
    |> Enum.group_by(fn {point, _} -> get_dimension(point, selector) end)
    |> Enum.sort()
    |> expand_by_dimension(0, factor, selector)
    |> Map.new()
  end

  defp expand_by_dimension([{a, a_set} | [{b, _} | _tail] = tail], offset, factor, selector) do
    update_set_by_dimension(a_set, offset, factor, selector) ++
      expand_by_dimension(tail, offset + (b - (a + 1)), factor, selector)
  end

  defp expand_by_dimension([{_, a_set}], offset, factor, selector) do
    update_set_by_dimension(a_set, offset, factor, selector)
  end

  defp update_set_by_dimension(set, offset, factor, selector) do
    Enum.map(set, fn {point, char} ->
      {update_dimension(point, selector, offset * factor - offset), char}
    end)
  end

  defp get_dimension({x, _y}, :x), do: x
  defp get_dimension({_x, y}, :y), do: y

  defp update_dimension({x, y}, :x, offset), do: {x + offset, y}
  defp update_dimension({x, y}, :y, offset), do: {x, y + offset}

  def parse(input) do
    for {line, y} <- Stream.with_index(input),
        {char, x} <- line |> String.codepoints() |> Enum.with_index(),
        char != ".",
        into: %{} do
      {{x, y}, char}
    end
  end

  def test_input(:part_1) do
    """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
  end
end
