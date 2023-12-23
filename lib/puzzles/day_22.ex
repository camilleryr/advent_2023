defmodule Day22 do
  @moduledoc "https://adventofcode.com/2023/day/22"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    5
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> drop_bricks()
    |> find_bricks_to_disintegrate()
    |> length()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    7
  """
  def_solution part_2(stream_input) do
    initial = stream_input |> parse() |> drop_bricks()

    initial
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.sort()
    |> Enum.map(&disolve(initial, &1, MapSet.new(initial)))
    |> IO.inspect()
    |> Enum.sum()
  end

  defp disolve(map, {id, cubes}, set) do
    map
    |> Map.drop(cubes)
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> drop_bricks()
    |> MapSet.new()
    |> MapSet.difference(set)
    |> Enum.map(fn {_, id} -> id end)
    |> Enum.uniq()
    |> Kernel.--([id])
    |> length()
  end

  defp to_grid(bricks) do
    for {id, cubes} <- bricks, cube <- cubes do
      {cube, id}
    end
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp graph(grid) do
    Enum.group_by(
      grid,
      fn {{x, _y, z}, _cubes} -> {x, z} end,
      fn {_, cubes} -> cubes end
    )
    |> print_grid(transformer: &transform/1, dir: :rev)

    Enum.group_by(
      grid,
      fn {{_x, y, z}, _cubes} -> {y, z} end,
      fn {_, cubes} -> cubes end
    )
    |> print_grid(transformer: &transform/1, dir: :rev)
  end

  defp transform(nil), do: " ---- "

  defp transform(list) do
    case list |> List.flatten() |> Enum.uniq() do
      [single] -> " " <> String.pad_leading(to_string(single), 4, "0") <> " "
      _multi -> " ???? "
    end
  end

  defp find_bricks_to_disintegrate(map) do
    bricks = map |> Enum.group_by(fn {_cube, id} -> id end, fn {cube, _id} -> cube end)

    bricks
    |> Enum.filter(fn {id, cubes} ->
      id
      |> get_supported(cubes, map)
      |> Enum.all?(fn supported_id ->
        bricks
        |> Map.get(supported_id)
        |> is_supported?(supported_id, id, map)
      end)
    end)
  end

  defp get_supported(id, cubes, state) do
    cubes
    |> Enum.map(fn {x, y, z} -> Map.get(state, {x, y, z + 1}) end)
    |> Enum.reject(fn val -> val in [id, nil] end)
    |> Enum.uniq()
  end

  defp is_supported?(cubes, id, dissolved_id, state) do
    cubes
    |> Enum.map(fn {x, y, z} -> Map.get(state, {x, y, z - 1}) end)
    |> Enum.reject(fn val -> val in [id, dissolved_id, nil] end)
    |> Enum.any?(& &1)
  end

  defp drop_bricks(bricks) do
    bricks
    |> Enum.reduce(%{}, fn {id, cubes}, state ->
      cubes |> drop_brick(state) |> Map.new(fn cube -> {cube, id} end) |> Map.merge(state)
    end)
  end

  defp drop_brick(cubes, state) do
    next_cubes = cubes |> Enum.map(fn {x, y, z} -> {x, y, z - 1} end)

    if valid?(next_cubes, state) do
      drop_brick(next_cubes, state)
    else
      cubes
    end
  end

  defp valid?(next_cubes, state) do
    Enum.all?(next_cubes, fn {_, _, z} = location ->
      not Map.has_key?(state, location) and z > 0
    end)
  end

  defp parse(stream_input) do
    stream_input
    |> Stream.with_index()
    |> Stream.map(fn {line, idx} -> {idx, parse_line(line)} end)
    |> Enum.sort_by(fn {_id, cube} -> cube |> Enum.map(&elem(&1, 2)) |> Enum.min() end)
  end

  defp parse_line(line) do
    [x1, y1, z1, x2, y2, z2] = line |> String.split(~w(, ~)) |> Enum.map(&String.to_integer/1)

    for x <- x1..x2, y <- y1..y2, z <- z1..z2 do
      {x, y, z}
    end
  end

  def test_input(:part_1) do
    """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """
  end
end
