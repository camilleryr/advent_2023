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
    initial_state = %{location: start, visited: MapSet.new([]), distance: 0}

    find_longest_path({[initial_state], nil}, map, destination)
  end

  defp find_longest_path({[], longest}, _, _), do: longest.distance

  defp find_longest_path({states, longest}, map, destination) do
    states
    |> Enum.reduce({[], longest}, fn %{
                                       location: location,
                                       visited: visited,
                                       distance: current_distance
                                     },
                                     {states_acc, longest_acc} ->
      next =
        map
        |> Map.fetch!(location)
        |> Enum.reject(fn {crossroad, _distance} ->
          MapSet.member?(visited, crossroad)
        end)
        |> Enum.map(fn {crossroad, distance} ->
          %{
            location: crossroad,
            visited: MapSet.put(visited, crossroad),
            distance: current_distance + distance
          }
        end)

      {completed, rest} = Enum.split_with(next, &(&1.location == destination))

      next_longest_acc =
        case {completed, longest_acc} do
          {[%{distance: d1} = completed], %{distance: d2} = prev_longest} ->
            if d1 > d2, do: completed, else: prev_longest

          {[%{} = completed], nil} ->
            completed

          _ ->
            longest_acc
        end

      {rest ++ states_acc, next_longest_acc}
    end)
    |> find_longest_path(map, destination)
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
    |> prune()
  end

  defp prune(%{map: map} = state) do
    crossroads =
      map
      |> Enum.reject(fn {_key, cell} -> cell == "#" end)
      |> Enum.flat_map(fn {key, _cell} ->
        case possible_moves(map, key) do
          [_, _, _ | _] = moves -> [{key, moves}]
          _ -> []
        end
      end)
      |> Map.new()
      |> Map.put(state.start, possible_moves(map, state.start))
      |> Map.put(state.destination, possible_moves(map, state.destination))

    contracted_map =
      crossroads
      |> Map.new(fn {key, dirs} ->
        {key, Enum.flat_map(dirs, &walk_to_crossroad(key, &1, crossroads, map, 1))}
      end)

    %{state | map: contracted_map}
  end

  # {crossraod_xy, distance}
  defp walk_to_crossroad(p1, p2, crossroads, map, distance) do
    possible_moves(map, p2)
    |> Enum.reject(&(&1 == p1))
    |> case do
      [p3] -> walk_to_crossroad(p2, p3, crossroads, map, distance + 1)
      _ when is_map_key(crossroads, p2) -> [{p2, distance}]
      _ -> []
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
