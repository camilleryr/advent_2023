defmodule Day5 do
  @moduledoc "https://adventofcode.com/2023/day/5"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    35
  """
  def_solution [preserve_newlines: true], part_1(stream_input) do
    {seeds, maps} = stream_input |> parse()

    seeds
    |> Enum.map(&map(&1, :seed, maps))
    |> Enum.min()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    46
  """
  def_solution [preserve_newlines: true], part_2(stream_input) do
    {seeds, crosswalks} =
      stream_input
      |> parse(fn seeds ->
        seeds
        |> Enum.chunk_every(2)
        |> Enum.map(fn [start, length] -> start..(start + length) end)
      end)

    find_min_location(0, seeds, crosswalks)
  end

  defp find_min_location(location, seeds, crosswalks) do
    seed = rev_map(location, :location, crosswalks)

    if Enum.any?(seeds, fn seed_range -> seed in seed_range end) do
      location
    else
      find_min_location(location + 1, seeds, crosswalks)
    end
  end

  defp rev_map(id, type, maps) do
    case Enum.find(maps, fn {{_source, destination}, _map} -> destination == type end) do
      nil ->
        id

      {{source, _destination}, crosswalks} ->
        id |> rev_crosswalk(crosswalks) |> rev_map(source, maps)
    end
  end

  defp rev_crosswalk(id, crosswalks) do
    Enum.find_value(crosswalks, id, fn {_, {range, diff}} ->
      if id in range, do: id + diff
    end)
  end

  defp map(id, type, maps) do
    case Enum.find(maps, fn {{source, _destination}, _map} -> source == type end) do
      nil ->
        id

      {{_source, destination}, crosswalks} ->
        id |> crosswalk(crosswalks) |> map(destination, maps)
    end
  end

  defp crosswalk(id, crosswalks) do
    Enum.find_value(crosswalks, id, fn {{range, diff}, _} ->
      if id in range, do: id + diff
    end)
  end

  def parse(stream_input, seed_transform \\ &Function.identity/1) do
    stream_input
    |> Stream.chunk_while([], &chunk_by_new_line/2, fn acc -> {:cont, Enum.reverse(acc), []} end)
    |> Enum.reduce({[], []}, &reduce_chunk(&1, &2, seed_transform))
  end

  defp reduce_chunk(["seeds: " <> seed_string], {[], []}, seed_transform) do
    {seed_string |> line_to_nums() |> seed_transform.(), []}
  end

  defp reduce_chunk([header | rest], {seeds, acc}, _) do
    [[_, source, destination]] = Regex.scan(~r/(\w+)-to-(\w+).+/, header)

    crosswalks =
      rest
      |> Enum.map(fn line ->
        [destination_start, source_start, length] = line_to_nums(line)

        {
          {source_start..(source_start + length), destination_start - source_start},
          {destination_start..(destination_start + length), source_start - destination_start}
        }
      end)

    {seeds, [{{String.to_atom(source), String.to_atom(destination)}, crosswalks} | acc]}
  end

  defp line_to_nums(line), do: line |> String.split(" ") |> Enum.map(&String.to_integer/1)

  defp chunk_by_new_line(nil, acc), do: {:cont, Enum.reverse(acc), []}
  defp chunk_by_new_line(line, acc), do: {:cont, [line | acc]}

  def test_input(:part_1) do
    """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """
  end
end
