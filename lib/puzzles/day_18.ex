defmodule Day18 do
  @moduledoc "https://adventofcode.com/2023/day/18"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    62
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, &parse_line/1)
  end

  defp get_boundary([a | [b | _] = rest]), do: distance(a, b) + get_boundary(rest)
  defp get_boundary(_), do: 0

  defp distance({x, ay}, {x, by}), do: abs(max(ay, by) - min(ay, by))
  defp distance({ax, y}, {bx, y}), do: abs(max(ax, bx) - min(ax, bx))

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    952408144115
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input, &parse_line_2/1)
  end

  defp do_solve(stream_input, parser) do
    points = stream_input |> Enum.map(&parser.(&1)) |> Enum.reduce([{0, 0}], &build_polygon/2)
    area = shoelace_theorum(points)
    interior_points = picks_theorem(points)

    area + interior_points
  end

  # https://en.wikipedia.org/wiki/Pick%27s_theorem
  defp picks_theorem(points), do: points |> get_boundary() |> div(2) |> Kernel.+(1)

  # https://en.wikipedia.org/wiki/Shoelace_formula
  defp shoelace_theorum(points), do: points |> do_shoelace() |> abs() |> div(2)
  defp do_shoelace([{ax, ay} | [{bx, by} | _] = rest]), do: ax * by - ay * bx + do_shoelace(rest)
  defp do_shoelace(_), do: 0

  defp build_polygon({dir, num}, [point | _] = path) do
    [next(dir, point, num) | path]
  end

  defp next("L", {x, y}, num), do: {x - num, y}
  defp next("R", {x, y}, num), do: {x + num, y}
  defp next("U", {x, y}, num), do: {x, y - num}
  defp next("D", {x, y}, num), do: {x, y + num}

  defp parse_line(line) do
    [_all, dir, num] = Regex.run(~r/(\w) (\d+).+/, line)
    {dir, String.to_integer(num)}
  end

  defp parse_line_2(line) do
    [_all, hex_num, hex_dir] = Regex.run(~r/\w \d+ \(#(.{5})(.)\)/, line)
    {num, ""} = Integer.parse(hex_num, 16)

    {to_dir(hex_dir), num}
  end

  defp to_dir("0"), do: "R"
  defp to_dir("1"), do: "D"
  defp to_dir("2"), do: "L"
  defp to_dir("3"), do: "U"

  def test_input(:part_1) do
    """
    R 6 (#70c710)
    D 5 (#0dc571)
    L 2 (#5713f0)
    D 2 (#d2c081)
    R 2 (#59c680)
    D 2 (#411b91)
    L 5 (#8ceee2)
    U 2 (#caa173)
    L 1 (#1b58a2)
    U 2 (#caa171)
    R 2 (#7807d2)
    U 3 (#a77fa3)
    L 2 (#015232)
    U 2 (#7a21e3)
    """
  end
end
