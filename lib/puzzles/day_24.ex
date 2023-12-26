defmodule Day24 do
  @moduledoc "https://adventofcode.com/2023/day/24"
  import Advent2023

  def_solution part_1(stream_input) do
    do_part_1(stream_input, 200_000_000_000_000, 400_000_000_000_000)
  end

  @doc ~S"""
  ## Example
    iex> test_input(:part_1) |> Advent2023.stream() |> do_part_1(7, 27)
    2
  """
  def do_part_1(stream, min, max) do
    stream
    |> parse()
    |> Enum.map(fn parsed -> %{parsed: parsed, equation: to_line_equation(parsed)} end)
    |> find_intersections()
    |> Enum.filter(&inside_range(&1, min, max))
    |> Enum.count()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
  end

  defp inside_range(%{intersection: {x, y}} = config, min, max) do
    is_in?(x, min, max) and
      is_in?(y, min, max) and
      future_intersection?(config, 1) and
      future_intersection?(config, 2)
  end

  defp is_in?(x, min, max), do: x >= min and x <= max

  defp future_intersection?(%{intersection: {ix, iy}} = config, id) do
    {{px, py, _pz}, {vx, vy, _vz}} = config[:parsed][id]

    is_in?(px + vx, min(px, ix), max(px, ix)) and is_in?(py + vy, min(py, iy), max(py, iy))
  end

  defp find_intersections([]), do: []

  defp find_intersections([head | rest]) do
    head
    |> find_intersections(rest)
    |> Enum.concat(find_intersections(rest))
  end

  # m1(x) + b1 = m2(x) + b2
  # b1 - b2 = (m2 - m1)(x)
  defp find_intersections(%{parsed: parsed1, equation: {m1, b1} = e1}, rest) do
    Enum.flat_map(rest, fn %{parsed: parsed2, equation: {m2, b2} = e2} ->
      if m1 == m2 do
        []
      else
        x = (b1 - b2) / (m2 - m1)

        [
          %{
            parsed: %{1 => parsed1, 2 => parsed2},
            equations: %{1 => e1, 2 => e2},
            intersection: {x, m1 * x + b1}
          }
        ]
      end
    end)
  end

  # y = mx + b
  defp to_line_equation({{px1, py1, _pz1}, {vx, vy, _vz}}) do
    m = vy / vx
    b = py1 - m * px1
    {m, b}
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      [px, py, pz, vx, vy, vz] =
        line
        |> String.split(~r/(, +| @ +)/)
        |> Enum.map(&String.to_integer/1)

      {{px, py, pz}, {vx, vy, vz}}
    end)
  end

  def test_input(:part_1) do
    """
    19, 13, 30 @ -2,  1, -2
    18, 19, 22 @ -1, -1, -2
    20, 25, 34 @ -2, -2, -4
    12, 31, 28 @ -1, -2, -1
    20, 19, 15 @  1, -5, -3
    """
  end
end
