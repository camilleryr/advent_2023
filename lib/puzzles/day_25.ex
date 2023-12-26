defmodule Day25 do
  @moduledoc "https://adventofcode.com/2023/day/25"
  import Advent2023

  @doc ~S"""
  ## Example
    iex> part_1(test_input(:part_1))
    54
  """
  def_solution part_1(stream_input) do
    stream_input
    |> to_graph()
    |> bisect(%{}, [])
    |> Enum.map(&length/1)
    |> Enum.product()
  end

  defp bisect(graph, heat_map, attempts) do
    IO.inspect(length(attempts))
    vertices = Graph.vertices(graph)

    heat_map =
      Enum.reduce(1..100, heat_map, fn _, heat_map ->
        v1 = Enum.random(vertices)
        v2 = Enum.random(vertices)
        path = Graph.dijkstra(graph, v1, v2) |> to_edges()

        path
        |> Enum.frequencies()
        |> Map.merge(heat_map, fn _key, v1, v2 -> v1 + v2 end)
      end)

    [[v1, v2] | _] =
      edges =
      heat_map
      |> Enum.sort_by(fn {_key, val} -> val end, :desc)
      |> Enum.map(&elem(&1, 0))
      |> select_edges([])

    maybe_bisected =
      Enum.reduce(edges, graph, fn [vv1, vv2], g ->
        Graph.delete_edge(g, vv1, vv2)
      end)

    if Graph.dijkstra(maybe_bisected, v1, v2) do
      bisect(graph, heat_map, [edges | attempts])
    else
      IO.inspect(edges)
      Graph.components(maybe_bisected)
    end
  end

  defp select_edges(_, [_1, _2, _3] = selected), do: selected

  defp select_edges([[v1, v2] = next | edges], selected) do
    if Enum.any?(selected, fn [s1, s2] -> v1 == s1 or v1 == s2 or v2 == s1 or v2 == s2 end) do
      select_edges(edges, selected)
    else
      select_edges(edges, [next | selected])
    end
  end

  defp to_edges([v1 | [v2 | _] = rest]), do: [Enum.sort([v1, v2]) | to_edges(rest)]
  defp to_edges(_), do: []

  defp to_graph(stream) do
    graph = Graph.new(type: :undirected)

    for line <- stream, [v1 | rest] = String.split(line, ~r/:? /), v2 <- rest, reduce: graph do
      acc ->
        Graph.add_edge(acc, v1, v2)
    end
  end

  def test_input(:part_1) do
    """
    jqt: rhn xhk nvd
    rsh: frs pzl lsr
    xhk: hfx
    cmg: qnr nvd lhk bvb
    rhn: xhk bvb hfx
    bvb: xhk hfx
    pzl: lsr hfx nvd
    qnr: nvd
    ntq: jqt hfx bvb xhk
    nvd: lhk
    lsr: lhk
    rzs: qnr cmg lsr rsh
    frs: qnr lhk lsr
    """
  end
end
