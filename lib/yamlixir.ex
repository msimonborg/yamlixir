defmodule Yamlixir do
  @moduledoc ~S"""
  Yaml parser for Elixir.
  """

  @type yaml :: String.t() | charlist
  @type options :: keyword
  @type decoded :: [any]

  @default_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  @doc ~S"""
  Decodes a string of valid Yaml into Elixir data.

  Returns `{:ok, parsed}`.

  ## Examples

      iex> Yamlixir.decode("")
      {:ok, []}

      iex> Yamlixir.decode("---")
      {:ok, [%{}]}

      iex> Yamlixir.decode(":")
      {:error, %Yamlixir.DecodingError{}}

      iex> Yamlixir.decode("a: b\nc: d")
      {:ok, [%{"a" => "b", "c" => "d"}]}

  """
  @spec decode(yaml, options) :: {:ok, decoded}
  def decode(yaml, options \\ []), do: do_decode(yaml, options)

  @doc ~S"""
  The same as `decode/2` but raises a `Yamlixir.DecodingError` exception if it fails.
  Returns the decoded yaml otherwise.

  ## Examples

      iex> Yamlixir.decode!("")
      []

      iex> Yamlixir.decode!("---")
      [%{}]

      iex> Yamlixir.decode!(":")
      ** (Yamlixir.DecodingError) decoding error

      iex> Yamlixir.decode!("a: b\nc: d")
      [%{"a" => "b", "c" => "d"}]

  """
  @spec decode!(yaml, options) :: decoded
  def decode!(yaml, options \\ []) do
    case do_decode(yaml, options) do
      {:ok, decoded} -> decoded
      {:error, exception} -> raise exception
    end
  end

  defp do_decode(yaml, options) do
    options = Keyword.merge(options, @default_options)

    decoded =
      yaml
      |> :yamerl_constr.string(options)
      |> Yamlixir.YamerlParser.parse()

    {:ok, decoded}
  catch
    {:yamerl_exception, [{_, _, message, _, _, :no_matching_anchor, _, _}]} ->
      {:error, %Yamlixir.DecodingError{message: List.to_string(message)}}

    _, _ ->
      {:error, %Yamlixir.DecodingError{}}
  end
end
