defmodule Day13 do
  @moduledoc "https://adventofcode.com/2023/day/13"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    405
  """
  def_solution [preserve_newlines: true], part_1(stream_input) do
    stream_input
    |> parse()
    |> Stream.map(&to_rows_and_colums/1)
    |> Stream.map(&find_reflection/1)
    |> Stream.map(&score/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    400

    iex> part_2(test_input(:part_2))
    10
  """
  def_solution [preserve_newlines: true], part_2(stream_input) do
    parsed = stream_input |> parse() |> Enum.to_list()
    mirrors = Enum.map(parsed, fn grid -> grid |> to_rows_and_colums() |> find_reflection() end)

    parsed
    |> Enum.zip(mirrors)
    |> Enum.map(fn {grid, ignore} ->
      Enum.find_value(grid, fn {loc, cell} ->
        grid
        |> Map.put(loc, swap(cell))
        |> to_rows_and_colums()
        |> find_reflection(ignore)
      end)
    end)
    |> Stream.map(&score/1)
    |> Enum.sum()
  end

  defp swap("."), do: "#"
  defp swap("#"), do: "."

  defp score({:rows, val}), do: val
  defp score({:columns, val}), do: val * 100

  defp find_reflection(rows_and_columns, {ignore_type, ignore_value} \\ {:other, 0}) do
    rows_and_columns
    |> Enum.find_value(fn {type, rows_or_colums} ->
      to_ignore = if type == ignore_type, do: ignore_value + 1, else: 0

      if reflected_rows = do_find_reflection(rows_or_colums, to_ignore) do
        {type, reflected_rows - 1}
      end
    end)
  end

  defp do_find_reflection(rows_or_columns, to_ignore) do
    1..map_size(rows_or_columns)
    |> Enum.reject(&(&1 == to_ignore))
    |> Enum.find(&find_relection(rows_or_columns, &1, &1 - 1))
  end

  defp find_relection(rows_or_columns, right, left, reflected \\ false) do
    case {rows_or_columns[right], rows_or_columns[left], reflected} do
      {a, b, answer} when is_nil(a) or is_nil(b) -> answer
      {same, same, _} -> find_relection(rows_or_columns, right + 1, left - 1, true)
      _ -> false
    end
  end

  defp parse(stream_input) do
    stream_input
    |> Stream.chunk_while([], &chunk_newline/2, &chunk_newline/1)
    |> Stream.map(&to_grid/1)
  end

  defp to_rows_and_colums(grid) do
    %{rows: collect(grid, &elem(&1, 0)), columns: collect(grid, &elem(&1, 1))}
  end

  defp collect(grid, selector) do
    grid
    |> Enum.group_by(fn {loc, _cell} -> selector.(loc) end)
    |> Enum.sort()
    |> Enum.map(fn {_group, grouped} ->
      grouped
      |> Enum.sort()
      |> Enum.map(fn {_loc, cell} -> cell end)
      |> Enum.join()
    end)
    |> Enum.with_index(1)
    |> Map.new(fn {val, idx} -> {idx, val} end)
  end

  defp to_grid(rows) do
    for {row, y} <- Enum.with_index(rows),
        {cell, x} <- row |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, cell}
    end
  end

  defp chunk_newline(element \\ nil, acc)
  defp chunk_newline(nil, acc), do: {:cont, Enum.reverse(acc), []}
  defp chunk_newline(element, acc), do: {:cont, [element | acc]}

  def test_input(:part_1) do
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """
  end

  def test_input(:part_2) do
    """
    ..###..#....#..
    ##.....#.##.#..
    ###....#.##.#..
    ###.#..#....#..
    ..##.#........#
    ####...........
    ..##...##..##..
    ##...#.######.#
    ..#.#.########.
    ##....#.####.#.
    ##.#.####...###
    ##...#.#....#.#
    ##...##.#..#.##
    """
  end
end
