defmodule Mix.Tasks.GenPuzzle do
  @moduledoc """
    `mix gne_puzzle 1`
  """

  use Mix.Task

  @shortdoc "Solve a problem by day and part"
  def run([day]) do
    :inets.start()
    :ssl.start()

    gen_input_file(day)
    gen_puzzle_file(day)
  end

  defp gen_puzzle_file(day) do
    File.write("./lib/puzzles/day_#{day}.ex", puzzle_template(day))
  end

  defp gen_input_file(day) do
    input = get("input", day)

    File.write("./input/day_#{day}.txt", input)
  end

  defp get(path, day) do
    cookie = Application.get_env(:elixir, :aoc_cookie)
    base = "https://adventofcode.com/2023/day/#{day}"

    url =
      case path do
        "" -> base
        path -> "#{base}/#{path}"
      end
      |> to_charlist()

    {:ok, {_req, _headers, results}} =
      :httpc.request(
        :get,
        {url, [{~c"cookie", "session=" <> cookie}]},
        [{:ssl, [verify: :verify_none]}],
        []
      )

    results
  end

  defp puzzle_template(day) do
    ~s"""
    defmodule Day#{day} do
      @moduledoc "https://adventofcode.com/2023/day/#{day}"
      import Advent2023

      @doc ~S\"\"\"
      ## Example

        iex> part_1(test_input(:part_1))
      \"\"\"
      def_solution part_1(stream_input) do
        stream_input
      end

      @doc ~S\"\"\"
      ## Example

        iex> part_2(test_input(:part_1))
      \"\"\"
      def_solution part_2(stream_input) do
        stream_input
      end

      def test_input(:part_1) do
        \"\"\"
        \"\"\"
      end
    end
    """
    |> String.replace("\n\n", "\n")
    |> String.trim("\n")
    |> Code.format_string!()
  end
end
