defmodule Day23 do
  @moduledoc "https://adventofcode.com/2023/day/23"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    94
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> find_longest_path()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    154
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse(transformer: fn x -> if x == "#", do: x, else: "." end)
    |> find_longest_path()
  end

  defp find_longest_path(%{map: map, start: start, destination: destination}) do
    initial_state = %{location: start, visited: MapSet.new([])}

    find_longest_path({[initial_state], %{}, nil}, Map.put(map, start, "#"), destination)
  end

  defp find_longest_path({[], _, longest}, _, _), do: MapSet.size(longest.visited)

  defp find_longest_path({states, distance_map, longest}, map, destination) do
    states
    # |> tap(&IO.inspect(length(&1)))
    |> Enum.reduce({[], distance_map, longest}, fn %{location: location, visited: visited},
                                                   {states_acc, distance_map_acc, longest_acc} ->
      next_distance = MapSet.size(visited) + 1

      next =
        map
        |> possible_moves(location)
        |> Enum.reject(fn move ->
          longest = Map.get(distance_map_acc, move)
          if longest, do: IO.inspect("at #{next_distance} but have #{longest}")

          MapSet.member?(visited, move) or (longest || 0) > next_distance
        end)
        |> Enum.map(fn next_location ->
          %{location: next_location, visited: MapSet.put(visited, next_location)}
        end)

      {completed, rest} = Enum.split_with(next, &(&1.location == destination))

      next_longest_acc =
        case {completed, longest_acc} do
          {[%{visited: v1} = completed], %{visited: v2} = prev_longest} ->
            if MapSet.size(v1) > MapSet.size(v2), do: completed, else: prev_longest

          {[%{} = completed], nil} ->
            completed

          _ ->
            longest_acc
        end

      next_distance_map_acc =
        next
        |> Map.new(fn x -> {x.location, next_distance} end)
        |> then(&Map.merge(distance_map_acc, &1))

      # print_grid(next_distance_map_acc, transformer: &transform/1)

      {rest ++ states_acc, next_distance_map_acc, next_longest_acc}
    end)
    |> find_longest_path(map, destination)
  end

  def transform(nil), do: " -- "

  def transform(int) do
    " " <> String.pad_leading(to_string(int), 2, "0") <> " "
  end

  defp parse(stream_input, opts \\ []) do
    transformer = Keyword.get(opts, :transformer, & &1)

    for {line, y} <- Enum.with_index(stream_input),
        {cell, x} <- line |> String.graphemes() |> Enum.with_index(),
        reduce: %{map: %{}, start: nil, destination: nil} do
      %{map: map, start: start, destination: destination} ->
        transformed = transformer.(cell)
        point = {x, y}
        maybe_start = if transformed == ".", do: start || point, else: start
        maybe_destination = if transformed == ".", do: point, else: destination

        %{
          map: Map.put(map, point, transformed),
          start: maybe_start,
          destination: maybe_destination
        }
    end
  end

  def possible_moves(map, {x, y} = vertex) when :erlang.map_get(vertex, map) == ">",
    do: [{x + 1, y}]

  def possible_moves(map, {x, y} = vertex) when :erlang.map_get(vertex, map) == "v",
    do: [{x, y + 1}]

  def possible_moves(map, {x, y} = vertex) when :erlang.map_get(vertex, map) == "<",
    do: [{x - 1, y}]

  def possible_moves(map, {x, y} = vertex) when :erlang.map_get(vertex, map) == "^",
    do: [{x, y - 1}]

  def possible_moves(map, {x, y}) do
    Enum.filter(
      [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}],
      fn neighbor -> Map.get(map, neighbor) not in ["#", nil] end
    )
  end

  def test_input(:part_1) do
    """
    #.#####################
    #.......#########...###
    #######.#########.#.###
    ###.....#.>.>.###.#.###
    ###v#####.#v#.###.#.###
    ###.>...#.#.#.....#...#
    ###v###.#.#.#########.#
    ###...#.#.#.......#...#
    #####.#.#.#######.#.###
    #.....#.#.#.......#...#
    #.#####.#.#.#########v#
    #.#...#...#...###...>.#
    #.#.#v#######v###.###v#
    #...#.>.#...>.>.#.###.#
    #####v#.#.###v#.#.###.#
    #.....#...#...#.#.#...#
    #.#########.###.#.#.###
    #...###...#...#...#.###
    ###.###.#.###v#####v###
    #...#...#.#.>.>.#.>.###
    #.###.###.#.###.#.#v###
    #.....###...###...#...#
    #####################.#
    """
  end
end
