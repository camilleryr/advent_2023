defmodule Day16 do
  @moduledoc "https://adventofcode.com/2023/day/16"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    46
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> do_solve({{-1, 0}, :right})
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    51
  """
  def_solution part_2(stream_input) do
    map = parse(stream_input)
    {{max, _}, _} = Enum.max(map)

    map
    |> originating_beams(max)
    |> Enum.chunk_every(div(max * 4, System.schedulers_online()))
    |> Task.async_stream(fn chunk -> Enum.map(chunk, &do_solve(map, &1)) end, ordered: false)
    |> Stream.flat_map(fn {:ok, vals} -> vals end)
    |> Enum.max()
  end

  defp originating_beams(:top, max), do: Enum.map(0..max, fn x -> {{x, -1}, :down} end)
  defp originating_beams(:bottom, max), do: Enum.map(0..max, fn x -> {{x, max + 1}, :up} end)
  defp originating_beams(:left, max), do: Enum.map(0..max, fn x -> {{-1, x}, :right} end)
  defp originating_beams(:right, max), do: Enum.map(0..max, fn x -> {{max + 1, x}, :left} end)

  defp originating_beams(map, max) when is_map(map) do
    Enum.flat_map([:left, :right, :top, :bottom], &originating_beams(&1, max))
  end

  defp do_solve(map, originating_beam) do
    {[originating_beam], %{}}
    |> simulate(map)
    |> map_size()
  end

  defp simulate({[], history}, _map), do: history

  defp simulate({light_beams, history}, map) do
    light_beams
    |> Enum.reduce({[], history}, &do_reduce(&1, &2, map))
    |> simulate(map)
  end

  defp do_reduce({point, dir}, {next_beams, history_acc} = acc, map) do
    next_point = next_point(dir, point)

    with cell when is_binary(cell) <- Map.get(map, next_point),
         all_next_dirs = next_dirs(dir, cell),
         [_ | _] = next_dirs <- Enum.reject(all_next_dirs, &prune(&1, next_point, history_acc)) do
      {next_beams(next_dirs, next_point, next_beams),
       next_history(history_acc, next_point, next_dirs)}
    else
      _ -> acc
    end
  end

  defp next_history(history_acc, next_point, next_dirs) do
    if Map.has_key?(history_acc, next_point) do
      Map.update!(history_acc, next_point, fn map_set ->
        Enum.reduce(next_dirs, map_set, &MapSet.put(&2, &1))
      end)
    else
      Map.put(history_acc, next_point, MapSet.new(next_dirs))
    end
  end

  defp next_beams([], _, next_beams), do: next_beams

  defp next_beams([next_dir | tail], next_point, next_beams),
    do: [{next_point, next_dir} | next_beams(tail, next_point, next_beams)]

  defp prune(next_dir, next_point, history_acc) do
    case Map.get(history_acc, next_point) do
      nil -> false
      map_set -> MapSet.member?(map_set, next_dir)
    end
  end

  defp next_point(:left, {x, y}), do: {x - 1, y}
  defp next_point(:right, {x, y}), do: {x + 1, y}
  defp next_point(:up, {x, y}), do: {x, y - 1}
  defp next_point(:down, {x, y}), do: {x, y + 1}

  defp next_dirs(dir, "."), do: [dir]

  defp next_dirs(:left, "/"), do: [:down]
  defp next_dirs(:right, "/"), do: [:up]
  defp next_dirs(:up, "/"), do: [:right]
  defp next_dirs(:down, "/"), do: [:left]

  defp next_dirs(:left, "\\"), do: [:up]
  defp next_dirs(:right, "\\"), do: [:down]
  defp next_dirs(:up, "\\"), do: [:left]
  defp next_dirs(:down, "\\"), do: [:right]

  defp next_dirs(dir, "|") when dir in [:left, :right], do: [:up, :down]
  defp next_dirs(dir, "|"), do: [dir]

  defp next_dirs(dir, "-") when dir in [:up, :down], do: [:left, :right]
  defp next_dirs(dir, "-"), do: [dir]

  defp parse(input) do
    for {line, y} <- Enum.with_index(input),
        {cell, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, cell}
    end
  end

  def test_input(:part_1) do
    ~S"""
    .|...\....
    |.-.\.....
    .....|-...
    ........|.
    ..........
    .........\
    ..../.\\..
    .-.-/..|..
    .|....-|.\
    ..//.|....
    """
  end
end
