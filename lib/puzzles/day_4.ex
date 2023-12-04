defmodule Day4 do
  @moduledoc "https://adventofcode.com/2023/day/4"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    13
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Stream.map(&parse_line/1)
    |> Stream.map(fn {_game_number, numbers} -> calculate_score(numbers) end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    30
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Stream.map(&parse_line/1)
    |> Map.new(fn {card_num, nums} -> {card_num, add_wins(card_num, nums)} end)
    |> get_winnings()
    |> Map.values()
    |> Enum.sum()
  end

  defp add_wins(card_num, nums) do
    wins =
      case nums.winning_numbers |> MapSet.intersection(nums.numbers) |> MapSet.size() do
        0 -> []
        size -> Enum.to_list((card_num + 1)..(card_num + size))
      end

    Map.put(nums, :wins, wins)
  end

  def get_winnings(card_details) do
    starting_acc = Map.new(card_details, fn {card_num, _dets} -> {card_num, 1} end)

    card_details
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce(starting_acc, fn key, acc ->
      instances = Map.get(acc, key)

      card_details
      |> get_in([key, :wins])
      |> Map.new(fn card -> {card, instances} end)
      |> Map.merge(acc, fn _key, val_1, val_2 -> val_1 + val_2 end)
    end)
  end

  @doc ~S"""
  ## Example
    iex> parse_line("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53")
    {1, %{winning_numbers: MapSet.new([41, 48, 83, 86, 17]), numbers: MapSet.new([83, 86,  6, 31, 17,  9, 48, 53])}}
  """
  def parse_line("Card " <> line) do
    [[game_number], winning_numbers, numbers] =
      line
      |> String.split([": ", " | "])
      |> Enum.map(fn numbers ->
        numbers
        |> String.trim()
        |> String.split(~r/\W+/)
        |> Enum.map(&String.to_integer/1)
      end)

    {game_number, %{winning_numbers: MapSet.new(winning_numbers), numbers: MapSet.new(numbers)}}
  end

  @doc ~S"""
  ## Example
    iex> calculate_score(%{winning_numbers: MapSet.new([41, 48, 83, 86, 17]), numbers: MapSet.new([83, 86,  6, 31, 17,  9, 48, 53])})
    8
  """
  def calculate_score(%{winning_numbers: winning_numbers, numbers: numbers}) do
    winning_numbers
    |> MapSet.intersection(numbers)
    |> MapSet.size()
    |> case do
      0 -> 0
      intersection -> 2 |> :math.pow(intersection - 1) |> floor()
    end
  end

  def test_input(:part_1) do
    """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """
  end
end
