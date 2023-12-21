defmodule Day21 do
  @moduledoc "https://adventofcode.com/2023/day/21"
  import Advent2023

  def_solution part_1(stream_input) do
    do_solve(stream_input, 64)
  end

  @doc ~S"""
  ## Example
    iex> test_input(:part_1) |> Advent2023.stream() |> do_solve(100)
    6536
  """
  def do_solve(stream_input, steps) do
    {map, starting_point} = stream_input |> parse()
    map = map |> expand()

    starting_point
    |> walk(map, steps)
    |> MapSet.size()
  end

  defp walk(starting_point, map, total) do
    positions = MapSet.new([starting_point])
    do_walk({positions, map}, total, 0)
  end

  defp do_walk({positions, _map}, total, total), do: positions

  defp do_walk({positions, map}, total, iterations) do
    positions
    |> Enum.reduce({MapSet.new(), map}, fn position, {position_acc, map} ->
      neighbors = position |> neighbors()
      # map = if Enum.all?(neighbors, &Map.has_key?(map, &1)), do: map, else: expand(map)

      next_position_acc =
        neighbors
        |> Enum.filter(fn neighbor ->
          map[neighbor] in [".", "S"] and neighbor not in position_acc
        end)
        |> MapSet.new()
        |> MapSet.union(position_acc)

      {next_position_acc, map}
    end)
    |> tap(&graph/1)
    |> do_walk(total, iterations + 1)
  end

  def expand(map) do
    {{{min_x, min_y}, _}, {{max_x, max_y}, _}} = Enum.min_max_by(map, &elem(&1, 0))
    xx = max_x - min_x + 1
    yy = max_y - min_y + 1

    Enum.reduce(
      [{-xx, -yy}, {0, -yy}, {xx, -yy}, {-xx, 0}, {xx, 0}, {-xx, yy}, {0, yy}, {xx, yy}],
      map,
      fn {x_off, y_off}, acc ->
        map
        |> Map.new(fn {{x, y}, char} -> {{x + x_off, y + y_off}, char} end)
        |> Map.merge(acc)
      end
    )
  end

  defp neighbors({x, y}), do: [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]

  def graph({positions, map}) do
    IO.puts(IO.ANSI.clear())

    positions
    |> Map.new(fn key -> {key, IO.ANSI.red() <> "O" <> IO.ANSI.reset()} end)
    |> then(&Map.merge(map, &1))
    |> print_grid()

    Process.sleep(250)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
  end

  defp parse(stream_input) do
    for {line, y} <- Enum.with_index(stream_input),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        reduce: {%{}, nil} do
      {acc, starting_point} ->
        point = {x, y}
        {Map.put(acc, point, char), if(char == "S", do: point, else: starting_point)}
    end
  end

  def test_input(:part_1) do
    """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........

    """
  end
end
