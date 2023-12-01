defmodule Day1 do
  @moduledoc "https://adventofcode.com/2023/day/1"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    142
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Stream.map(fn line ->
      [first | _rest] = rest = line |> String.replace(~r/\D/, "") |> String.codepoints()

      first
      |> Kernel.<>(List.last(rest))
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_2))
    281
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Stream.map(&replace/1)
    |> Enum.sum()
  end

  @replacements %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }
  @overlapping_regex ~r/(?=(\d|#{@replacements |> Map.keys() |> Enum.join("|")}))/

  defp replace(string) do
    [first_digit | _] = digits = Regex.scan(@overlapping_regex, string)
    converted_last = digits |> List.last() |> convert()

    first_digit |> convert() |> Kernel.<>(converted_last) |> String.to_integer()
  end

  defp convert([_, capture]) when is_map_key(@replacements, capture), do: @replacements[capture]
  defp convert([_, capture]), do: capture

  def test_input(:part_1) do
    """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """
  end

  def test_input(:part_2) do
    """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """
  end
end
