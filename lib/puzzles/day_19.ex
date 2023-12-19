defmodule Day19 do
  @moduledoc "https://adventofcode.com/2023/day/19"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    19114
  """
  def_solution part_1(stream_input) do
    %{module: module, starting_function: starting_function, parts: parts} =
      stream_input |> parse_stream() |> parse_module()

    parts
    |> Enum.filter(fn part ->
      apply(module, starting_function, [part]) == :accepted
    end)
    |> Enum.flat_map(&Map.values/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    167409079868000
  """
  def_solution part_2(stream_input) do
    {conditions, _} = stream_input |> parse_stream()
    conditions_map = Map.new(conditions)

    conditions_map
    |> expand_conditions()
    |> Enum.map(&build_possible_range/1)
    # |> IO.inspect()
    # |> reduce_ranges()
    # |> IO.inspect()
    |> Enum.map(&get_possible_solutions/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> reduce_ranges([%{"a" => 1..4000, "m" => 839..1800, "s" => 1..4000, "x" => 1..4000}, %{"a" => 1..4000, "m" => 1..900, "s" => 1..4000, "x" => 1..4000}])
    [%{"a" => 1..4000, "m" => 1..1800, "s" => 1..4000, "x" => 1..4000}]
  """
  def reduce_ranges(list) do
    case do_reduce_ranges(list) do
      ^list -> list
      new_list -> reduce_ranges(new_list)
    end
  end

  defp do_reduce_ranges([head | rest]) do
    {to_reduce, rest} =
      Enum.split_with(
        rest,
        &Enum.all?(&1, fn {key, range} -> not Range.disjoint?(range, head[key]) end)
      )
    # |> IO.inspect(label: inspect(head))

    new_head =
      Enum.reduce(to_reduce, head, fn part_ranges, acc ->
        Map.new(acc, fn {key, %{first: first, last: last}} ->
          range = part_ranges[key]
          {key, min(first, range.first)..max(last, range.last)}
        end)
      end)

    [new_head | do_reduce_ranges(rest)]
  end

  defp do_reduce_ranges([]), do: []

  defp get_possible_solutions(ranges) do
    ranges
    |> Map.values()
    |> Enum.map(&Range.size/1)
    |> Enum.product()
  end

  @doc """
  ## Examples
    iex> build_possible_range([{"s", "<", "1351"}, {"a", "<", "2006"}, {"x", "<", "1416"}])
    %{"a" => 1..2005, "m" => 1..4000, "s" => 1..1350, "x" => 1..1415}

    iex> build_possible_range(["true", {"m", "<", "1801"}, {"m", ">", "838"}])
    %{"x" => 1..4000, "m" => 839..1800, "a" => 1..4000, "s" => 1..4000}
  """
  def build_possible_range(conds) do
    initial = %{"x" => 1..4000, "m" => 1..4000, "a" => 1..4000, "s" => 1..4000}

    Enum.reduce(conds, initial, fn
      "true", acc ->
        acc

      {attr, operator, number}, acc ->
        Map.update!(acc, attr, &update_range(&1, operator, String.to_integer(number)))
    end)
  end

  defp update_range(%{first: first, last: last}, "<", number) when first < number do
    first..min(last, number - 1)
  end

  defp update_range(%{first: first, last: last}, ">", number) when last > number do
    max(first, number + 1)..last
  end

  defp update_range(nil, _, _), do: nil

  defp expand_conditions(map) do
    expand_conditions("in", [], map)
  end

  defp expand_conditions("R", _, _), do: []
  defp expand_conditions("A", conds, _), do: [conds]

  defp expand_conditions(key, conds, map) do
    map[key]
    |> Enum.reduce({[], []}, fn {cond, next}, {acc, negated_conds} ->
      updated_conds = [cond | negated_conds] ++ conds
      next_acc = [{next, updated_conds} | acc]
      negated = negate(cond)
      updated_negated_conds = [negated | negated_conds]

      {next_acc, updated_negated_conds}
    end)
    |> elem(0)
    |> Enum.flat_map(fn {next, next_conds} -> expand_conditions(next, next_conds, map) end)
  end

  defp negate({attr, ">", num}), do: {attr, "<", to_string(String.to_integer(num) + 1)}
  defp negate({attr, "<", num}), do: {attr, ">", to_string(String.to_integer(num) - 1)}
  defp negate("true"), do: "true"

  defp parse_module({conditions, parts}) do
    _module = build_module(Day19Runner, conditions)

    %{
      parts: parts,
      starting_function: "in" |> to_name() |> String.to_atom(),
      module: Day19Runner
    }
  end

  defp build_module(name, conditions) do
    """
    defmodule #{name} do
      #{conditions |> Enum.map(&build_function/1) |> Enum.join("\n\n")}
    end
    """
    |> Code.eval_string()
  end

  defp build_function({name, conditions}) do
    conds =
      conditions
      |> Enum.map(fn
        {{attr, operator, val}, expression} ->
          "#{to_attr(attr)} #{operator} #{val} -> #{to_expression(expression)}"

        {attr, expression} ->
          "#{to_attr(attr)} -> #{to_expression(expression)}"
      end)
      |> Enum.join("\n")

    """
    def #{to_name(name)}(part) do
      # IO.inspect("#{name}")
      cond do
        #{conds}
      end
    end
    """
  end

  defp to_expression("A"), do: ":accepted"
  defp to_expression("R"), do: ":rejected"
  defp to_expression(function), do: "#{to_name(function)}(part)"

  defp parse_stream(stream_input) do
    stream_input
    |> Enum.reduce({[], []}, fn
      <<"{", _::binary>> = line, {conditions, parts} ->
        {part, _} = "%" |> Kernel.<>(line) |> String.replace("=", ": ") |> Code.eval_string()
        {conditions, [part | parts]}

      line, {conditions, parts} ->
        [name | cond_strings] = String.split(line, ["{", "}", ","], trim: true)
        parsed_conds = parse_conds(cond_strings)
        {[{name, parsed_conds} | conditions], parts}
    end)
  end

  defp parse_conds([head | rest]) do
    next =
      case Regex.run(~r/(\w+)([><])(\d+)\:(\w+)/, head) do
        [_, attr, operator, arg, expression] -> {{attr, operator, arg}, expression}
        nil -> {"true", head}
      end

    [next | parse_conds(rest)]
  end

  defp parse_conds([]), do: []

  defp to_name(name), do: "day_19_#{name}"

  defp to_attr(part_attr) when part_attr in ~w(x m a s), do: "part[:#{part_attr}]"
  defp to_attr(other), do: other

  def test_input(:part_1) do
    """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """
  end
end
