defmodule Day3 do
  @moduledoc "https://adventofcode.com/2023/day/3"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    4361
  """
  def_solution part_1(stream_input) do
    schematic = parse(stream_input)

    schematic
    |> get_part_numbers()
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    467835
  """
  def_solution part_2(stream_input) do
    schematic = parse(stream_input)
    part_numbers = get_part_numbers(schematic)

    schematic
    |> Enum.filter(fn {_loc, cell} -> cell == "*" end)
    |> Enum.flat_map(fn {loc, _cell} ->
      case get_adjacent_part_numbers(loc, part_numbers) do
        [part_1, part_2] -> [part_1 * part_2]
        _ -> []
      end
    end)
    |> Enum.sum()
  end

  defp get_adjacent_part_numbers({gear_x, gear_y}, part_numbers) do
    Enum.flat_map(part_numbers, fn {{x_range, part_y}, number} ->
      for x <- (gear_x - 1)..(gear_x + 1),
          y <- (gear_y - 1)..(gear_y + 1) do
        {x, y}
      end
      |> Enum.any?(fn {x, y} -> y == part_y and x in x_range end)
      |> if(do: [number], else: [])
    end)
  end

  defp symbol_adjacent?({{x_range, num_y}, _cell}, schematic) do
    for x <- (x_range.first - 1)..(x_range.last + 1),
        y <- (num_y - 1)..(num_y + 1),
        not (y == num_y and x in x_range) do
      {x, y}
    end
    |> Enum.any?(fn loc ->
      case Map.get(schematic, loc) do
        cell when is_binary(cell) -> Regex.match?(~r/[^\d.]/, cell)
        _ -> false
      end
    end)
  end

  defp parse(input) do
    for {line, y} <- Enum.with_index(input),
        {char, x} <- line |> String.codepoints() |> Enum.with_index(),
        into: %{} do
      {{x, y}, char}
    end
  end

  defp get_part_numbers(schematic) do
    schematic
    |> Enum.sort_by(fn {{x, y}, _cell} -> {y, x} end)
    |> Enum.chunk_by(fn {{_x, y}, cell} -> {y, Regex.match?(~r/\d/, cell)} end)
    |> Enum.filter(fn [{_loc, cell} | _] -> Regex.match?(~r/\d/, cell) end)
    |> Enum.map(fn [{{first_x, y}, first_cell} | rest] ->
      rest
      |> Enum.reduce({Range.new(first_x, first_x), first_cell}, fn {{x, _}, cell},
                                                                   {range_acc, num_acc} ->
        {%{range_acc | last: x}, num_acc <> cell}
      end)
      |> then(fn {range, num_string} -> {{range, y}, String.to_integer(num_string)} end)
    end)
    |> Enum.filter(&symbol_adjacent?(&1, schematic))
  end

  def test_input(:part_1) do
    """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
  end
end
