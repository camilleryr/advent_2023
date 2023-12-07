defmodule Day7 do
  @moduledoc "https://adventofcode.com/2023/day/7"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    6440
  """
  def_solution part_1(stream_input) do
    solve_day_7(stream_input)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    5905
  """
  def_solution part_2(stream_input) do
    solve_day_7(stream_input, &jack_to_joker/1, &apply_jokers/1)
  end

  defp solve_day_7(
         stream_input,
         card_transformer \\ &Function.identity/1,
         hand_transformer \\ &Function.identity/1
       ) do
    stream_input
    |> Stream.map(&parse_line(&1, card_transformer, hand_transformer))
    |> Enum.sort()
    |> Enum.with_index(1)
    |> Enum.map(fn {{_type, _hand, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  defp parse_line(
         <<a::binary-size(1), b::binary-size(1), c::binary-size(1), d::binary-size(1),
           e::binary-size(1), " ", rest::binary>>,
         card_transformer,
         hand_transformer
       ) do
    hand = Enum.map([a, b, c, d, e], fn card -> card |> card_transformer.() |> parse_card() end)

    {type_score(hand, hand_transformer), hand, String.to_integer(rest)}
  end

  defp type_score(hand, hand_transformer) do
    case hand |> Enum.frequencies() |> hand_transformer.() |> Map.values() |> Enum.sort(:desc) do
      [5] -> 7
      [4 | _] -> 6
      [3, 2 | _] -> 5
      [3 | _] -> 4
      [2, 2 | _] -> 3
      [2 | _] -> 2
      _ -> 1
    end
  end

  defp parse_card("A"), do: 14
  defp parse_card("K"), do: 13
  defp parse_card("Q"), do: 12
  defp parse_card("J"), do: 11
  defp parse_card("T"), do: 10
  defp parse_card(num), do: String.to_integer(num)

  defp jack_to_joker("J"), do: "1"
  defp jack_to_joker(other), do: other

  defp apply_jokers(hand_frequencies) when is_map_key(hand_frequencies, 1) do
    {number_of_jokers, remaining} = Map.pop(hand_frequencies, 1)

    remaining
    |> Enum.max_by(fn {_card, frequency} -> frequency end, &>=/2, fn -> {1, 0} end)
    |> then(fn {card, frequency} -> Map.put(remaining, card, frequency + number_of_jokers) end)
  end

  defp apply_jokers(hand_frequencies), do: hand_frequencies

  def test_input(:part_1) do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
  end
end
