defmodule Yamlixir.YamerlParser do
  @moduledoc false

  def parse(nil, _options), do: %{}
  def parse(yaml, options) when is_list(yaml), do: Enum.map(yaml, &parse(&1, options))

  def parse(yaml, options) do
    yaml
    |> do_parse(options)
    |> extract()
  end

  def extract(nil), do: %{}
  def extract(parsed), do: parsed

  def do_parse({:yamerl_doc, document}, options), do: do_parse(document, options)
  def do_parse({:yamerl_null, :yamerl_node_null, _tag, _loc}, _options), do: nil

  def do_parse({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}, options),
    do: Enum.map(seq, &do_parse(&1, options))

  def do_parse({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}, options),
    do: tuples_to_map(map_tuples, %{}, options)

  def do_parse({_yamler_element, _yamler_node_element, _tag, _loc, elem}, _options), do: elem

  def tuples_to_map([], map, _options), do: map

  def tuples_to_map([{key, val} | rest], map, options) do
    case key do
      {:yamerl_seq, :yamerl_node_seq, _tag, _log, _seq, _n} ->
        tuples_to_map(
          rest,
          Map.put_new(map, do_parse(key, options), do_parse(val, options)),
          options
        )

      {_yamler_element, _yamler_node_element, _tag, _log, name} ->
        tuples_to_map(
          rest,
          Map.put_new(map, key(name, options[:keys]), do_parse(val, options)),
          options
        )
    end
  end

  def key(name, :atoms), do: String.to_atom(name)
  def key(name, :atoms!), do: String.to_existing_atom(name)
  def key(name, _), do: name
end
