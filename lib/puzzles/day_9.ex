defmodule Day9 do
  @moduledoc "https://adventofcode.com/2023/day/9"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    114
  """
  def_solution part_1(stream_input) do
    do_solve(stream_input, &Enum.reverse/1)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    2
  """
  def_solution part_2(stream_input) do
    do_solve(stream_input, &Function.identity/1)
  end

  defp do_solve(stream_input, transformer) do
    stream_input
    |> Enum.map(&to_int/1)
    |> Enum.map(&predict(&1, transformer))
    |> Enum.map(fn [[prediction | _] | _] -> prediction end)
    |> Enum.sum()
  end

  @doc """
  ## Example
    iex> predict([0, 3, 6, 9, 12, 15])
    [[18, 15, 12, 9, 6, 3, 0], [3, 3, 3, 3, 3, 3], [0, 0, 0, 0, 0]]

    iex> predict([1, 3, 6, 10, 15, 21])
    [[28, 21, 15, 10, 6, 3, 1], [7, 6, 5, 4, 3, 2], [1, 1, 1, 1, 1], [0, 0, 0, 0]]

  """
  def predict(measurements, transformer \\ &Enum.reverse/1) do
    initial = transformer.(measurements)

    initial
    |> find_deltas([initial])
    |> add_prediction([], 0)
  end

  defp add_prediction([[a | _] = head | tail], acc, last_diff) do
    next_diff = last_diff + a
    add_prediction(tail, [[next_diff | head] | acc], next_diff)
  end

  defp add_prediction([], acc, _), do: acc

  defp find_deltas(measurements, acc) do
    {delta, all_zeros?} = find_delta(measurements, true)
    next = [delta | acc]

    if all_zeros? do
      next
    else
      find_deltas(delta, next)
    end
  end

  defp find_delta([a | [b | _] = rest], all_zeros?) do
    diff = a - b
    {rem_delta, rem_all_zeros?} = find_delta(rest, all_zeros?)
    {[diff | rem_delta], rem_all_zeros? and diff == 0}
  end

  defp find_delta(_, all_zeros?), do: {[], all_zeros?}

  defp to_int(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def test_input(:part_1) do
    """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
  end
end
