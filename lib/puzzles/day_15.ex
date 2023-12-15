defmodule Day15 do
  @moduledoc "https://adventofcode.com/2023/day/15"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    1320
  """
  def_solution part_1(stream_input) do
    stream_input
    |> split()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    145
  """
  def_solution part_2(stream_input) do
    initial_boxes = Map.new(0..255, fn x -> {x, []} end)

    stream_input
    |> parse()
    |> Enum.reduce(initial_boxes, fn {label, _, _} = step, boxes ->
      Map.update!(boxes, hash(label), &manage_lenses(&1, step))
    end)
    |> score()
  end

  @doc ~S"""
  ## Example
    iex> hash("HASH")
    52
  """
  def hash(string) do
    string
    |> to_charlist()
    |> Enum.reduce(0, fn ascii_code, acc ->
      rem((acc + ascii_code) * 17, 256)
    end)
  end

  defp score(boxes) do
    for {box, lenses} <- boxes,
        {{_label, focal_length}, lens_index} <- Enum.with_index(lenses, 1),
        reduce: 0 do
      acc -> acc + (box + 1) * lens_index * focal_length
    end
  end

  defp manage_lenses(lenses, {label, "=", focal_length}) do
    replace_or_add(lenses, label, focal_length)
  end

  defp manage_lenses(lenses, {label, "-", _}) do
    Enum.reject(lenses, fn {lens_label, _} -> lens_label == label end)
  end

  defp replace_or_add([], label, focal_length), do: [{label, focal_length}]

  defp replace_or_add([{label, _} | rest], label, focal_length),
    do: [{label, focal_length} | rest]

  defp replace_or_add([head | rest], label, focal_length),
    do: [head | replace_or_add(rest, label, focal_length)]

  defp parse(input) do
    input
    |> split()
    |> Enum.map(fn step ->
      [^step, label, operation, focal_length] = Regex.run(~r|(\w+)([=-])(\d?)|, step)
      {label, operation, if(focal_length == "", do: nil, else: String.to_integer(focal_length))}
    end)
  end

  defp split(input), do: Enum.flat_map(input, &String.split(&1, ","))

  def test_input(:part_1) do
    """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """
  end
end
