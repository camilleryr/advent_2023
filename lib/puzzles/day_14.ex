defmodule Day14 do
  @moduledoc "https://adventofcode.com/2023/day/14"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    136
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> tilt(:north)
    |> score()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    64
  """
  def_solution part_2(stream_input) do
    {repeat_idx, cycle_start_idx, repeat_state} =
      stream_input
      |> parse()
      |> find_repeating_cycle()

    cycle_size = repeat_idx - cycle_start_idx
    remaining_cycles = 1_000_000_000 - repeat_idx
    remainder = rem(remaining_cycles, cycle_size)

    1..remainder
    |> Enum.reduce(repeat_state, fn _, state_acc -> cycle(state_acc) end)
    |> score()
  end

  defp find_repeating_cycle(state),
    do: find_repeating_cycle(state, Map.put(%{}, hash(state), 0), 1)

  defp find_repeating_cycle(state, history, idx) do
    next_state = cycle(state)
    hash = hash(next_state)

    case Map.get(history, hash) do
      repeat_idx when is_integer(repeat_idx) -> {idx, repeat_idx, next_state}
      nil -> find_repeating_cycle(next_state, Map.put(history, hash, idx), idx + 1)
    end
  end

  defp hash(state), do: Base.encode64(:erlang.term_to_binary(state.map))

  defp score(%{map: map}) do
    map
    |> Enum.filter(fn {_, cell} -> cell == "O" end)
    |> Enum.map(fn {{_, y}, _} -> y end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> expected = test_input(:part_1_1_cycle) |> Advent2023.stream() |> parse() |> Map.get(:map)
    iex> test_input(:part_1) |> Advent2023.stream() |> parse() |> cycle() |> Map.get(:map)
    expected
  """
  def cycle(state) do
    Enum.reduce([:north, :west, :south, :east], state, &tilt(&2, &1))
  end

  @doc ~S"""
  ## Example
    iex> expected = test_input(:part_1_tilted_north) |> Advent2023.stream() |> parse() |> Map.get(:map)
    iex> test_input(:part_1) |> Advent2023.stream() |> parse() |> tilt(:north) |> Map.get(:map)
    expected

    iex> expected = test_input(:part_1_tilted_south) |> Advent2023.stream() |> parse() |> Map.get(:map)
    iex> test_input(:part_1) |> Advent2023.stream() |> parse() |> tilt(:south) |> Map.get(:map)
    expected

    iex> expected = test_input(:part_1_tilted_east) |> Advent2023.stream() |> parse() |> Map.get(:map)
    iex> test_input(:part_1) |> Advent2023.stream() |> parse() |> tilt(:east) |> Map.get(:map)
    expected

    iex> expected = test_input(:part_1_tilted_west) |> Advent2023.stream() |> parse() |> Map.get(:map)
    iex> test_input(:part_1) |> Advent2023.stream() |> parse() |> tilt(:west) |> Map.get(:map)
    expected
  """
  def tilt(%{map: map} = state, dir) do
    # IO.inspect(dir)

    map
    |> to_lines(dir)
    # |> IO.inspect()
    |> Enum.flat_map(&do_tilt(dir, &1, edge(dir, state), []))
    |> Map.new()
    |> then(fn map -> %{state | map: map} end)
  end

  defp edge(:north, state), do: state.max_x
  defp edge(:south, state), do: state.min_x
  defp edge(:east, state), do: state.max_y
  defp edge(:west, state), do: state.min_y

  defp to_lines(map, :north),
    do: map |> Enum.sort(:desc) |> Enum.chunk_by(fn {{x, _y}, _} -> x end)

  defp to_lines(map, :south),
    do: map |> Enum.sort(:asc) |> Enum.chunk_by(fn {{x, _y}, _} -> x end)

  defp to_lines(map, :east),
    do:
      map
      |> Enum.sort_by(fn {{x, y}, _} -> {y, -x} end, :asc)
      |> Enum.chunk_by(fn {{_, y}, _} -> y end)

  defp to_lines(map, :west),
    do:
      map
      |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end, :asc)
      |> Enum.chunk_by(fn {{_, y}, _} -> y end)

  @doc ~S"""
  ## Example
    iex> do_tilt(:north, [{{10, 9}, "#"}, {{10, 7}, "O"}, {{10, 5}, "#"}, {{10, 4}, "O"}], 10, [])
    [{{10, 4}, "O"}, {{10, 5}, "#"}, {{10, 8}, "O"}, {{10, 9}, "#"}]

    iex> do_tilt(:south, [{{1, 1}, "#"}, {{1, 2}, "#"}, {{1, 5}, "O"}, {{1, 7}, "O"}, {{1, 9}, "O"}, {{1, 10}, "O"}], 1, [])
    [{{1, 6}, "O"}, {{1, 5}, "O"}, {{1, 4}, "O"}, {{1, 3}, "O"}, {{1, 2}, "#"}, {{1, 1}, "#"}]

    iex> do_tilt(:east, [{{10, 7}, "O"}, {{5, 7}, "O"}, {{4, 7}, "#"}, {{2, 7}, "O"}, {{1, 7}, "O"}], 10, [])
    [{{2, 7}, "O"}, {{3, 7}, "O"}, {{4, 7}, "#"}, {{9, 7}, "O"}, {{10, 7}, "O"}]
  """
  def do_tilt(_, [], _, acc), do: acc

  def do_tilt(:north, [{{_, y}, "#"} = kvp | rest], _, acc),
    do: do_tilt(:north, rest, y - 1, [kvp | acc])

  def do_tilt(:north, [{{x, _}, "O" = cell} | rest], y, acc),
    do: do_tilt(:north, rest, y - 1, [{{x, y}, cell} | acc])

  def do_tilt(:south, [{{_, y}, "#"} = kvp | rest], _, acc),
    do: do_tilt(:south, rest, y + 1, [kvp | acc])

  def do_tilt(:south, [{{x, _}, "O" = cell} | rest], y, acc),
    do: do_tilt(:south, rest, y + 1, [{{x, y}, cell} | acc])

  def do_tilt(:east, [{{x, _}, "#"} = kvp | rest], _, acc),
    do: do_tilt(:east, rest, x - 1, [kvp | acc])

  def do_tilt(:east, [{{_, y}, "O" = cell} | rest], x, acc),
    do: do_tilt(:east, rest, x - 1, [{{x, y}, cell} | acc])

  def do_tilt(:west, [{{x, _}, "#"} = kvp | rest], _, acc),
    do: do_tilt(:west, rest, x + 1, [kvp | acc])

  def do_tilt(:west, [{{_, y}, "O" = cell} | rest], x, acc),
    do: do_tilt(:west, rest, x + 1, [{{x, y}, cell} | acc])

  def parse(stream_input) do
    for {line, y} <- stream_input |> Enum.reverse() |> Enum.with_index(1),
        {cell, x} <- line |> String.graphemes() |> Enum.with_index(1),
        reduce: %{min_x: 1, max_x: 1, min_y: 1, max_y: 1, map: %{}} do
      %{max_x: max_x, max_y: max_y, map: map} = acc ->
        next_map = if cell in ~w(O #), do: Map.put(map, {x, y}, cell), else: map
        %{acc | max_x: max(max_x, x), max_y: max(max_y, y), map: next_map}
    end
  end

  def test_input(:part_1) do
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
  end

  def test_input(:part_1_tilted_north) do
    """
    OOOO.#.O..
    OO..#....#
    OO..O##..O
    O..#.OO...
    ........#.
    ..#....#.#
    ..O..#.O.O
    ..O.......
    #....###..
    #....#....
    """
  end

  def test_input(:part_1_tilted_south) do
    """
    .....#....
    ....#....#
    ...O.##...
    ...#......
    O.O....O#O
    O.#..O.#.#
    O....#....
    OO....OO..
    #OO..###..
    #OO.O#...O
    """
  end

  def test_input(:part_1_tilted_east) do
    """
    ....O#....
    .OOO#....#
    .....##...
    .OO#....OO
    ......OO#.
    .O#...O#.#
    ....O#..OO
    .........O
    #....###..
    #..OO#....
    """
  end

  def test_input(:part_1_tilted_west) do
    """
    O....#....
    OOO.#....#
    .....##...
    OO.#OO....
    OO......#.
    O.#O...#.#
    O....#OO..
    O.........
    #....###..
    #OO..#....
    """
  end

  def test_input(:part_1_1_cycle) do
    """
    .....#....
    ....#...O#
    ...OO##...
    .OO#......
    .....OOO#.
    .O#...O#.#
    ....O#....
    ......OOOO
    #...O###..
    #..OO#....
    """
  end
end
