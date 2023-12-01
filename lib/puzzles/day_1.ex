defmodule Day1 do
  import Advent2023

  @doc ~S"""
  --- Day 1: Trebuchet?! ---
  Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.

  You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.

  Collect stars by solving puzzles.  Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first.  Each puzzle grants one star. Good luck!

  You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").

  As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.

  The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.

  For example:

  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet

  In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.

  Consider your entire calibration document. What is the sum of all of the calibration values?


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
  --- Part Two ---
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
