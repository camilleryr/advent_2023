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
    |> __part_1__()
  end

  defp replace(<<head::binary-size(1), rest::binary>> = string) do
    case string do
      "one" <> _rest -> "1" <> replace(rest)
      "two" <> _rest -> "2" <> replace("wo" <> rest)
      "three" <> _rest -> "3" <> replace("hree" <> rest)
      "four" <> _rest -> "4" <> replace("our" <> rest)
      "five" <> _rest -> "5" <> replace("ive" <> rest)
      "six" <> _rest -> "6" <> replace("ix" <> rest)
      "seven" <> _rest -> "7" <> replace("even" <> rest)
      "eight" <> _rest -> "8" <> replace("ight" <> rest)
      "nine" <> _rest -> "9" <> replace("ine" <> rest)
      _ -> head <> replace(rest)
    end
  end

  defp replace(""), do: ""

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
