defmodule Day17 do
  @moduledoc "https://adventofcode.com/2023/day/17"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    102
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, 1..3)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    94

    iex> part_2(test_input(:part_2))
    71
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input, 4..10)
  end

  defp do_solve(stream_input, path_range) do
    map = stream_input |> parse()
    {{start, _}, {finish, _}} = Enum.min_max(map)

    [
      %{dir: :south, weight: 0, path: [start]},
      %{dir: :east, weight: 0, path: [start]}
    ]
    |> find_path(finish, map, path_range)
    |> Map.get(:weight)
  end

  defp find_path(incomplete, destination, map, path_range, best \\ nil)

  defp find_path([], _destination, _map, _path_range, best), do: best

  defp find_path(states, destination, map, path_range, best) do
    states =
      for %{dir: dir, path: [point | _rest] = path, weight: weight} = state <- states,
          {next_dir, next_path, path_weight} <-
            get_next_paths(dir, point, path, map, path_range),
          weight + path_weight < best[:weight] do
        %{state | dir: next_dir, path: next_path ++ path, weight: weight + path_weight}
      end

    {complete, incomplete} = Enum.split_with(states, &(List.first(&1.path) == destination))
    maybe_best = Enum.min_by(complete, & &1.weight, &<=/2, fn -> nil end)
    best = if maybe_best[:weight] < best[:weight], do: maybe_best, else: best

    incomplete
    |> Enum.group_by(fn %{path: [h | _], dir: dir} ->
      {if(dir in [:north, :south], do: 1, else: 2), h}
    end)
    |> Enum.map(fn {_key, vals} -> Enum.min_by(vals, & &1.weight) end)
    |> find_path(destination, map, path_range, best)
  end

  defp get_next_paths(facing_dir, point, path, map, path_range) do
    for length <- path_range,
        dir <- get_dirs(facing_dir),
        options = get_options(dir, point, length),
        Enum.all?(options, &Map.has_key?(map, &1)),
        Enum.all?(options, &(&1 not in path)) do
      {dir, options, options |> Enum.map(&Map.fetch!(map, &1)) |> Enum.sum()}
    end
  end

  defp get_options(:north, {x, y}, length), do: Enum.map(length..1, &{x, y - &1})
  defp get_options(:south, {x, y}, length), do: Enum.map(length..1, &{x, y + &1})
  defp get_options(:east, {x, y}, length), do: Enum.map(length..1, &{x + &1, y})
  defp get_options(:west, {x, y}, length), do: Enum.map(length..1, &{x - &1, y})

  defp get_dirs(dir) when dir in [:north, :south], do: [:east, :west]
  defp get_dirs(dir) when dir in [:east, :west], do: [:north, :south]

  def parse(stream_input) do
    for {line, y} <- Stream.with_index(stream_input),
        {weight, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, String.to_integer(weight)}
    end
  end

  def test_input(:part_1) do
    """
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """
  end

  def test_input(:part_2) do
    """
    111111111111
    999999999991
    999999999991
    999999999991
    999999999991
    """
  end
end
