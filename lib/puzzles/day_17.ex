defmodule Day17 do
  @moduledoc "https://adventofcode.com/2023/day/17"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    102
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> find_shortest_distance(MapSet.new())
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
  end

  defp find_shortest_distance(map, removed_edges) do
    %{path: path, total_weight: total_weight} = dijkstra(map, {0, 0}, removed_edges)

    IO.inspect(path)
    case edge_to_remove(path) |> IO.inspect() do
      nil -> total_weight
      edge ->
        Process.sleep(100)
        find_shortest_distance(map, MapSet.put(removed_edges, edge))
    end
  end

  defp edge_to_remove([{_, rel}, {_, rel}, {v1, rel}, {v2, rel} | _]), do: {v1, v2}
  defp edge_to_remove([_ | rest]), do: edge_to_remove(rest)
  defp edge_to_remove([]), do: nil

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

  @doc """
  Copied from Advent21 Day15
  """
  def dijkstra(weight_map, starting_point, removed_edges) do
    distances = %{starting_point => {0, nil}}
    {destination, _} = Enum.max(weight_map)

    dijkstra(starting_point, :gb_trees.empty(), distances, weight_map, removed_edges, destination)
  end

  def dijkstra(destination, _queue, distances, _weights, _removed_edges, destination) do
    build_path(distances)
  end

  def dijkstra(vertex, queue, distances, weights, removed_edges, destination) do
    {current_distance, _parent} = distances[vertex]

    neighbors =
      vertex
      |> neightbors()
      |> Enum.filter(fn {p, _rel} ->
        Map.has_key?(weights, p) and
          not Map.has_key?(distances, p) and
          {vertex, p} not in removed_edges
      end)

    updated_distances =
      Enum.reduce(neighbors, distances, fn {neightbor, relationship}, d ->
        neighbor_weight = weights[neightbor]
        current_neighbor_distance = current_distance + neighbor_weight

        Map.update(
          d,
          neightbor,
          {current_neighbor_distance, {vertex, relationship}},
          fn existing_distance ->
            min(existing_distance, {current_neighbor_distance, {vertex, relationship}})
          end
        )
      end)

    updated_queue =
      Enum.reduce(neighbors, queue, fn {n, _}, acc -> put_queue(acc, updated_distances[n], n) end)

    {next_vertex, next_queue} = pop_queue(updated_queue)

    dijkstra(next_vertex, next_queue, updated_distances, weights, removed_edges, destination)
  end

  defp build_path(weight_map) do
    {destination, {total_weight, parent}} = Enum.max(weight_map)

    [parent, destination]
    |> build_path(weight_map)
    |> then(fn path -> %{total_weight: total_weight, path: path} end)
  end

  defp build_path([{v, _rel} = x | _] = path, distances_map) do
    case distances_map[v] do
      {_weight, nil} -> path
      {_weight, parent} -> build_path([parent | path], distances_map)
    end
  end

  def put_queue(tree, priority, value) do
    case :gb_trees.take_any(priority, tree) do
      {values, updated_tree} -> :gb_trees.insert(priority, [value | values], updated_tree)
      _ -> :gb_trees.insert(priority, [value], tree)
    end
  end

  def pop_queue(tree) do
    case :gb_trees.take_smallest(tree) do
      {_priority, [val], updated_tree} ->
        {val, updated_tree}

      {priority, [val | rest], updated_tree} ->
        {val, :gb_trees.insert(priority, rest, updated_tree)}
    end
  end

  def neightbors({x, y}) do
    [{{x, y - 1}, :up}, {{x + 1, y}, :right}, {{x, y + 1}, :down}, {{x - 1, y}, :left}]
  end
end
