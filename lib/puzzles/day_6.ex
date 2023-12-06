defmodule Day6 do
  @moduledoc "https://adventofcode.com/2023/day/6"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    288
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> Enum.map(&find_winning_margin_of_error/1)
    |> Enum.product()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    71503
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse(&String.replace(&1, " ", ""))
    |> Enum.map(&find_winning_margin_of_error/1)
    |> Enum.product()
  end

  @doc ~S"""
  ## Example
    iex> find_winning_margin_of_error(%{time: 7, distance: 9})
    4
  """
  def find_winning_margin_of_error(%{time: time, distance: distance}) do
    0..time
    |> Enum.filter(fn charging_time ->
      (charging_time * (time - charging_time)) > distance
    end)
    |> Enum.count()
  end

  defp parse(input, preprocess \\ &Function.identity/1) do
    input
    |> Enum.map(fn line ->
      [attr_str | values] = line |> String.downcase() |> preprocess.() |> String.split(~r/:?\W+/)
      attr = String.to_atom(attr_str)

      Enum.map(values, &%{attr => String.to_integer(&1)})
    end)
    |> Enum.zip()
    |> Enum.map(fn att_map -> att_map |> Tuple.to_list() |> Enum.reduce(&Map.merge/2) end)
  end

  def test_input(:part_1) do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
  end
end
