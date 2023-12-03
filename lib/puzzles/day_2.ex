defmodule Day2 do
  @moduledoc "https://adventofcode.com/2023/day/2"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    8
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Stream.map(&parse/1)
    |> Stream.map(fn {game, rounds} -> {game, get_rounds(rounds)} end)
    |> Stream.reject(fn {_game, max_cubes} ->
      Enum.any?(%{red: 12, green: 13, blue: 14}, fn {color, max} ->
        Map.get(max_cubes, color, 0) > max
      end)
    end)
    |> Stream.map(fn {game, _} -> game end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    2286
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Stream.map(&parse/1)
    |> Stream.map(fn {game, rounds} -> {game, get_rounds(rounds)} end)
    |> Stream.map(fn {_, cubes} -> cubes |> Map.values() |> Enum.product() end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> parse("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
    {1, [[{3, :blue}, {4, :red}], [{1, :red}, {2, :green}, {6, :blue}], [{2, :green}]]}
  """
  def parse("Game " <> line) do
    [game | rounds] = String.split(line, [": ", "; "])

    {String.to_integer(game), Enum.map(rounds, &parse_round/1)}
  end

  defp parse_round(round) do
    round
    |> String.split([" ", ", "])
    |> Enum.map(fn glob ->
      case Integer.parse(glob) do
        {int, _} -> int
        :error -> String.to_atom(glob)
      end
    end)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp get_rounds(rounds) do
    rounds
    |> List.flatten()
    |> Enum.reduce(%{}, fn {num, color}, acc ->
      Map.update(acc, color, num, fn existing -> max(num, existing) end)
    end)
  end

  def test_input(:part_1) do
    """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """
  end
end
