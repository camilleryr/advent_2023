defmodule Day8 do
  @moduledoc "https://adventofcode.com/2023/day/8"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    2

    iex> part_1(test_input(:part_1_2))
    6
  """
  def_solution part_1(stream_input) do
    {directions, map} = parse(stream_input)

    [{_, solution}] =
      directions
      |> Stream.cycle()
      |> Stream.transform("AAA", fn
        _direction, "ZZZ" = last -> {:halt, last}
        direction, next -> {[next], map |> Map.get(next) |> get_next(direction)}
      end)
      |> Stream.with_index(1)
      |> Enum.take(-1)

    solution
  end

  defp get_next({left, _}, "L"), do: left
  defp get_next({_, right}, "R"), do: right

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_2))
    6
  """
  def_solution part_2(stream_input) do
    {directions, map} = parse(stream_input)
    starting_nodes = map |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))

    starting_nodes
    |> Task.async_stream(&find_cycle(&1, directions, map), timeout: :infinity)
    |> Enum.flat_map(fn {:ok, stream} -> stream end)
    |> Enum.reduce(&lcm/2)
  end

  def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

	def lcm(0, 0), do: 0
	def lcm(a, b), do: floor((a*b)/gcd(a,b))

  defp find_cycle(starting_node, directions, map) do
    directions
    |> Stream.with_index()
    |> Stream.cycle()
    |> Enum.reduce_while([], fn
      direction, [] ->
        {:cont, [{starting_node, direction}]}

      next_direction, [{node, {direction, _dir_idx}} | _tail] = acc ->
        next_node = map |> Map.get(node) |> get_next(direction)
        next = {next_node, next_direction}

        if next in acc do
          {:halt, [next | acc]}
        else
          {:cont, [next | acc]}
        end
    end)
    |> then(fn [cycle_start | rest] = _all ->
      path = Enum.reverse(rest) |> Enum.with_index()
      cycle_starts_at = Enum.find_index(path, fn {x, _idx} -> x == cycle_start end)
      {_non_repeating, repeating} = Enum.split(path, cycle_starts_at)

      Enum.flat_map(repeating, &ends_with_z/1)
    end)
  end

  defp ends_with_z({{<<_::binary-size(2), last::binary-size(1)>>, _dir}, idx}) do
    if last == "Z", do: [idx], else: []
  end

  defp parse(stream_input) do
    Enum.reduce(stream_input, {nil, %{}}, fn
      line, {nil, %{}} ->
        {String.codepoints(line), %{}}

      <<a::binary-size(3), " = (", b::binary-size(3), ", ", c::binary-size(3), ")">>,
      {dir, acc} ->
        {dir, Map.put(acc, a, {b, c})}
    end)
  end

  def test_input(:part_1) do
    """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
  end

  def test_input(:part_1_2) do
    """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
  end

  def test_input(:part_2) do
    """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
  end
end
