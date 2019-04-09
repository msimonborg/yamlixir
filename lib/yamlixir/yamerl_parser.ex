defmodule Yamlixir.YamerlParser do
  @moduledoc false

  def parse(nil), do: %{}
  def parse(yaml) when is_list(yaml), do: Enum.map(yaml, &parse(&1))

  def parse(yaml) do
    yaml
    |> do_parse()
    |> extract()
  end

  def extract(nil), do: %{}
  def extract(parsed), do: parsed

  def do_parse({:yamerl_doc, document}), do: do_parse(document)
  def do_parse({:yamerl_null, :yamerl_node_null, _tag, _loc}), do: nil

  def do_parse({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}),
    do: Enum.map(seq, &do_parse(&1))

  def do_parse({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}),
    do: tuples_to_map(map_tuples, %{})

  def do_parse({_yamler_element, _yamler_node_element, _tag, _loc, elem}), do: elem

  def tuples_to_map([], map), do: map

  def tuples_to_map([{key, val} | rest], map) do
    case key do
      {:yamerl_seq, :yamerl_node_seq, _tag, _log, _seq, _n} ->
        tuples_to_map(rest, Map.put_new(map, do_parse(key), do_parse(val)))

      {_yamler_element, _yamler_node_element, _tag, _log, name} ->
        tuples_to_map(rest, Map.put_new(map, name, do_parse(val)))
    end
  end
end
