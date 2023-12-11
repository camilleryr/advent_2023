defmodule Day10 do
  @moduledoc "https://adventofcode.com/2023/day/10"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1_1))
    4

    iex> part_1(test_input(:part_1_2))
    8
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> find_loop()
    |> length()
    |> div(2)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_2_1))
    4

    iex> part_2(test_input(:part_2_2))
    8

    iex> part_2(test_input(:part_2_3))
    10
  """
  def_solution part_2(stream_input) do
    map = stream_input |> parse()
    loop = find_loop(map)

    map
    |> update_map(loop)
    |> expand_map()
    |> then(&find_interior({[{0, 0}], %{}}, &1))
    |> count_blocks()
  end

  defp count_blocks(interior) do
    keys = Map.keys(interior)
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(keys, fn {x, _} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(keys, fn {_, y} -> y end)
    points = for x <- min_x..max_x//3, y <- min_y..max_y//3, do: {x, y}

    points
    |> Enum.filter(&complete_square?(&1, interior))
    |> Enum.count()
  end

  defp complete_square?(point, interior) do
    point
    |> expand_point()
    |> Enum.all?(&Map.has_key?(interior, &1))
  end

  defp find_interior({[_ | _] = points, exterior}, map) do
    points
    |> Enum.reduce({[], exterior}, fn point, {points_acc, exterior_acc} ->
      neighbors = get_neighbors(point)

      next_points =
        Enum.filter(neighbors, fn neighbor ->
          map[neighbor] == "." and not Map.has_key?(exterior_acc, neighbor)
        end)

      {next_points ++ points_acc, Map.merge(exterior_acc, Map.take(map, neighbors))}
    end)
    |> find_interior(map)
  end

  defp find_interior({[], exterior}, map) do
    Map.drop(map, Map.keys(exterior))
  end

  defp get_neighbors({x, y}) do
    for x <- (x - 1)..(x + 1), y <- (y - 1)..(y + 1), do: {x, y}
  end

  defp update_map(map, [first, next | rest] = loop) do
    last = List.last(rest)
    starting_pipe = get_starting_pipe(last, first, next)

    map
    |> Map.new(fn {loc, char} -> if loc in loop, do: {loc, char}, else: {loc, "."} end)
    |> Map.put(first, starting_pipe)
  end

  defp get_starting_pipe({x, _}, {x, _}, {x, _}), do: "-"
  defp get_starting_pipe({_, y}, {_, y}, {_, y}), do: "|"

  # {0, 1} {0, 0} {1, 0}
  # {1, 0} {0, 0} {0, 1}
  defp get_starting_pipe({x, yy}, {x, y}, {xx, y}) when xx == x + 1 and yy == y + 1, do: "F"
  defp get_starting_pipe({xx, y}, {x, y}, {x, yy}) when xx == x + 1 and yy == y + 1, do: "F"

  # {0, 0} {1, 0} {1, 1}
  # {1, 1} {1, 0} {0, 0}
  defp get_starting_pipe({xx, y}, {x, y}, {x, yy}) when xx == x - 1 and yy == y + 1, do: "7"
  defp get_starting_pipe({x, yy}, {x, y}, {xx, y}) when xx == x - 1 and yy == y + 1, do: "7"

  # {1, 0} {1, 1} {0, 1}
  # {0, 1} {1, 1} {1, 0}
  defp get_starting_pipe({x, yy}, {x, y}, {xx, y}) when xx == x - 1 and yy == y - 1, do: "J"
  defp get_starting_pipe({xx, y}, {x, y}, {x, yy}) when xx == x - 1 and yy == y - 1, do: "J"

  # {0, 0} {0, 1} {1, 1}
  # {1, 1} {0, 1} {0, 0}
  defp get_starting_pipe({x, yy}, {x, y}, {xx, y}) when xx == x + 1 and yy == y - 1, do: "L"
  defp get_starting_pipe({xx, y}, {x, y}, {x, yy}) when xx == x + 1 and yy == y - 1, do: "L"

  defp find_loop(map) when is_map(map) do
    map
    |> Enum.find_value(fn {location, char} -> if char == "S", do: location end)
    |> List.duplicate(4)
    |> Enum.zip([:north, :south, :east, :west])
    |> Enum.map(&List.wrap/1)
    |> find_loop(map)
    |> then(fn [[_anchor | half_2], half_1] ->
      half_1
      |> Enum.reverse()
      |> Enum.concat(half_2)
      |> Enum.map(&elem(&1, 0))
      |> Enum.drop(-1)
    end)
  end

  defp find_loop(paths, map) do
    next_paths =
      Enum.flat_map(paths, fn [{location, direction} | _] = path ->
        case next(location, direction, map) do
          nil -> []
          next -> [[next | path]]
        end
      end)

    next_paths
    |> Enum.group_by(fn [{location, _} | _] -> location end)
    |> Map.values()
    |> Enum.find_value(fn grouped -> if length(grouped) == 2, do: grouped end)
    |> case do
      [_, _] = loop -> loop
      _ -> find_loop(next_paths, map)
    end
  end

  defp next({x, y}, :north, map) do
    next = {x, y - 1}

    case Map.get(map, next) do
      "|" -> {next, :north}
      "7" -> {next, :west}
      "F" -> {next, :east}
      _ -> nil
    end
  end

  defp next({x, y}, :south, map) do
    next = {x, y + 1}

    case Map.get(map, next) do
      "|" -> {next, :south}
      "L" -> {next, :east}
      "J" -> {next, :west}
      _ -> nil
    end
  end

  defp next({x, y}, :east, map) do
    next = {x + 1, y}

    case Map.get(map, next) do
      "-" -> {next, :east}
      "7" -> {next, :south}
      "J" -> {next, :north}
      _ -> nil
    end
  end

  defp next({x, y}, :west, map) do
    next = {x - 1, y}

    case Map.get(map, next) do
      "-" -> {next, :west}
      "L" -> {next, :north}
      "F" -> {next, :south}
      _ -> nil
    end
  end

  defp expand_map({loc, "-"}) do
    expand(loc, ~w"""
    . . .
    - - -
    . . .
    """)
  end

  defp expand_map({loc, "|"}) do
    expand(loc, ~w"""
    . | .
    . | .
    . | .
    """)
  end

  defp expand_map({loc, "L"}) do
    expand(loc, ~w"""
    . | .
    . L -
    . . .
    """)
  end

  defp expand_map({loc, "F"}) do
    expand(loc, ~w"""
    . . .
    . F -
    . | .
    """)
  end

  defp expand_map({loc, "J"}) do
    expand(loc, ~w"""
    . | .
    - J .
    . . .
    """)
  end

  defp expand_map({loc, "7"}) do
    expand(loc, ~w"""
    . . .
    - 7 .
    . | .
    """)
  end

  defp expand_map({loc, "."}) do
    expand(loc, ~w"""
    . . .
    . . .
    . . .
    """)
  end

  defp expand_map(map) when is_map(map) do
    map
    |> Enum.flat_map(&expand_map/1)
    |> Map.new()
  end

  defp expand({old_x, old_y}, expanded) do
    {old_x * 3, old_y * 3}
    |> expand_point()
    |> Enum.zip(expanded)
  end

  defp expand_point({x, y}) do
    [
      {x, y},
      {x + 1, y},
      {x + 2, y},
      {x, y + 1},
      {x + 1, y + 1},
      {x + 2, y + 1},
      {x, y + 2},
      {x + 1, y + 2},
      {x + 2, y + 2}
    ]
  end

  defp parse(input) do
    for {line, y} <- Stream.with_index(input),
        {char, x} <- line |> String.codepoints() |> Enum.with_index(),
        # char != ".",
        into: %{} do
      {{x, y}, char}
    end
  end

  def map_char("|"), do: "│"
  def map_char("-"), do: "─"
  def map_char("L"), do: "└"
  def map_char("J"), do: "┘"
  def map_char("7"), do: "┐"
  def map_char("F"), do: "┌"
  def map_char("S"), do: "S"
  def map_char(nil), do: "X"
  def map_char(_), do: "o"

  def test_input(:part_1_1) do
    """
    -L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF
    """
  end

  def test_input(:part_1_2) do
    """
    7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ
    """
  end

  def test_input(:part_2_0) do
    """
    S-7
    |.|
    L-J
    """
  end

  def test_input(:part_2_1) do
    """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
  end

  def test_input(:part_2_2) do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end

  def test_input(:part_2_3) do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
  end
end
