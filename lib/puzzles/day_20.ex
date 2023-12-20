defmodule Day20 do
  @moduledoc "https://adventofcode.com/2023/day/20"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1, 1))
    32000000

    iex> part_1(test_input(:part_1, 2))
    11687500
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> push_button(1000)
    |> score()
  end

  @doc ~S"""
  ## Example
    iex> part_2(File.read!("./input/day_20.txt"))
    247454898168563
  """
  def_solution part_2(stream_input) do
    initial_state = parse(stream_input)
    gates = get_gates(initial_state)

    {1, initial_state, gates}
    |> Stream.iterate(fn {idx, module_state, gates} ->
      {next_state, signals} = push_button(module_state)
      {idx + 1, next_state, get_next_gates(gates, idx, signals)}
    end)
    |> Stream.drop_while(fn {_, _, gates} ->
      not Enum.all?(gates, fn {_gate, val} -> is_integer(val) end)
    end)
    |> Enum.at(1)
    |> then(fn {_, _, cycled_gates} -> Map.values(cycled_gates) end)
    |> Enum.reduce(&lcm/2)
  end

  defp score(%{pulse_counter: %{low_pulse: low, high_pulse: high}}) do
    low * high
  end

  defp get_gates(module_state) do
    module_state
    |> Enum.find_value(fn {_key, config} ->
      if "rx" in Map.get(config, :destinations, []), do: config.state
    end)
    |> Map.keys()
    |> Map.new(fn gate -> {gate, nil} end)
  end

  defp get_next_gates(gates, idx, signals) do
    Map.new(gates, fn
      {gate, nil} ->
        val =
          Enum.find_value(signals, fn {_, type, origin} ->
            if origin == gate and type == :high_pulse, do: idx
          end)

        {gate, val}

      captured ->
        captured
    end)
  end

  defp push_button(module_state, total) do
    Enum.reduce(1..total, module_state, fn _, module_state ->
      {next, _} = push_button(module_state)
      next
    end)
  end

  defp push_button(module_state) do
    updated_module_state = update_in(module_state, [:pulse_counter, :low_pulse], &(&1 + 1))
    send_signal({updated_module_state, [{"broadcaster", :low_pulse, "button"}]}, [])
  end

  defp send_signal({module_state, []}, all_signals), do: {module_state, all_signals}

  defp send_signal({module_state, signals}, all_signals) do
    for {signal_destination, signal_type, signal_origin} <- signals,
        not is_nil(module_state[signal_destination]),
        reduce: {module_state, []} do
      {state_acc, signal_acc} ->
        # IO.inspect("#{signal_origin} -#{signal_type}-> #{signal_destination}")

        {next_state, signals} =
          handle_signal(state_acc, signal_destination, signal_type, signal_origin)

        {next_state, Enum.concat(signal_acc, signals)}
    end
    |> then(fn {_state, signals} = next ->
      send_signal(next, Enum.concat(signals, all_signals))
    end)
  end

  defp handle_signal(state, signal_destination, signal_type, signal_origin) do
    {next_module_state, signals} =
      handle_signal(state[signal_destination], signal_type, signal_origin)

    pulse_count = Enum.frequencies_by(signals, fn {_, pulse_type, _} -> pulse_type end)

    next_state =
      state
      |> put_in([signal_destination, :state], next_module_state)
      |> update_in([:pulse_counter], &Map.merge(&1, pulse_count, fn _key, v1, v2 -> v1 + v2 end))

    {next_state, signals}
  end

  # BUTTON MODULE
  defp handle_signal(%{type: :button, name: name, state: state} = module, :low_pulse, _) do
    {state, Enum.map(module.destinations, fn destination -> {destination, :low_pulse, name} end)}
  end

  # BROADCASTER MODULE
  defp handle_signal(%{type: :broadcaster, name: name, state: state} = module, :low_pulse, _) do
    {state, Enum.map(module.destinations, fn destination -> {destination, :low_pulse, name} end)}
  end

  # FLIP FLOP MODULE
  defp handle_signal(%{type: :flip_flop} = module, :high_pulse, _), do: {module.state, []}

  defp handle_signal(%{type: :flip_flop, state: :off, name: name} = module, :low_pulse, _) do
    {:on, Enum.map(module.destinations, fn destination -> {destination, :high_pulse, name} end)}
  end

  defp handle_signal(%{type: :flip_flop, state: :on, name: name} = module, :low_pulse, _) do
    {:off, Enum.map(module.destinations, fn destination -> {destination, :low_pulse, name} end)}
  end

  # CONJUNCTION MODULE
  defp handle_signal(%{type: :conjunction, name: name} = module, pulse, origin) do
    next_state = Map.replace!(module.state, origin, pulse)
    all_high? = next_state |> Map.values() |> Enum.all?(&(&1 == :high_pulse))
    next_pulse = if all_high?, do: :low_pulse, else: :high_pulse

    {next_state,
     Enum.map(module.destinations, fn destination -> {destination, next_pulse, name} end)}
  end

  defp parse(stream_input) do
    stream_input
    |> Map.new(&parse_line/1)
    |> update_conjuction_modules()
    |> Map.put(:pulse_counter, %{high_pulse: 0, low_pulse: 0})
  end

  defp update_conjuction_modules(modules) do
    conjuction_modules =
      Enum.flat_map(modules, fn {name, %{type: type}} ->
        if type == :conjunction, do: [name], else: []
      end)

    for {module, %{destinations: destinations}} <- modules,
        destination <- destinations,
        destination in conjuction_modules,
        reduce: modules do
      acc ->
        update_in(acc, [destination, :state], &Map.put(&1, module, :low_pulse))
    end
  end

  defp parse_line(line) do
    case line do
      <<"broadcaster", rest::binary>> ->
        {"broadcaster",
         %{
           name: "broadcaster",
           type: :broadcaster,
           state: nil,
           destinations: parse_destinations(rest)
         }}

      <<"%", rest::binary>> ->
        [name, rest] = String.split(rest, " ", parts: 2)

        {name,
         %{name: name, type: :flip_flop, state: :off, destinations: parse_destinations(rest)}}

      <<"&", rest::binary>> ->
        [name, rest] = String.split(rest, " ", parts: 2)

        {name,
         %{name: name, type: :conjunction, state: %{}, destinations: parse_destinations(rest)}}
    end
  end

  defp parse_destinations(line) do
    String.split(line, [" ", "->", ","], trim: true)
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: floor(a * b / gcd(a, b))

  def test_input(:part_1, 1) do
    """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """
  end

  def test_input(:part_1, 2) do
    """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """
  end
end
