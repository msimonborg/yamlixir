defmodule Yamlixir do
  @moduledoc ~S"""
  Simple YAML parser for Elixir.
  """

  @type yaml :: String.t() | charlist
  @type options :: keyword
  @type decoded :: [any]
  @type error :: Yamlixir.DecodingError.t()

  @default_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  @doc ~S"""
  Decodes a string of valid YAML into Elixir data.

  Returns `{:ok, decoded}` on success and `{:error, %Yamlixir.DecodingError{}}` on failure.

  ## Options

    * `:at` - Returns only the document at the given position in the list of documents. Expects input to be an integer.
    * `:keys` - Controls how keys in maps are decoded. Defaults to strings. Possible values are:
      * `:atoms` - keys are converted to atoms using `String.to_atom/1`
      * `:atoms!` - keys are converted to atoms using `String.to_existing_atom/1`

  ## Examples

      iex> Yamlixir.decode("")
      {:ok, []}

      iex> Yamlixir.decode("---")
      {:ok, [%{}]}

      iex> Yamlixir.decode(":")
      {:error, %Yamlixir.DecodingError{}}

      iex> Yamlixir.decode("a: b\nc: d")
      {:ok, [%{"a" => "b", "c" => "d"}]}

      iex> Yamlixir.decode("---\na: b\nc: d\n---\ne: f\ng: h")
      {:ok, [%{"a" => "b", "c" => "d"}, %{"e" => "f", "g" => "h"}]}

      iex> Yamlixir.decode("---\na: b\nc: d\n---\ne: f\ng: h", at: 0)
      {:ok, %{"a" => "b", "c" => "d"}}

      iex> Yamlixir.decode("---\na: b\nc: d\n---\ne: f\ng: h", at: -1)
      {:ok, %{"e" => "f", "g" => "h"}}

      iex> Yamlixir.decode("---\na: b\nc: d\n---\ne: f\ng: h", at: -1, keys: :atoms)
      {:ok, %{e: "f", g: "h"}}

  """
  @spec decode(yaml, options) :: {:ok, decoded} | {:error, error}
  def decode(yaml, options \\ []), do: do_decode(yaml, options)

  @doc ~S"""
  The same as `decode/2` but raises a `Yamlixir.DecodingError` exception if it fails.
  Returns the decoded YAML otherwise.

  ## Examples

      iex> Yamlixir.decode!("")
      []

      iex> Yamlixir.decode!("---")
      [%{}]

      iex> Yamlixir.decode!(":")
      ** (Yamlixir.DecodingError) decoding error

      iex> Yamlixir.decode!("a: b\nc: d")
      [%{"a" => "b", "c" => "d"}]

      iex> Yamlixir.decode!("---\na: b\nc: d\n---\ne: f\ng: h")
      [%{"a" => "b", "c" => "d"}, %{"e" => "f", "g" => "h"}]

      iex> Yamlixir.decode!("---\na: b\nc: d\n---\ne: f\ng: h", at: 0)
      %{"a" => "b", "c" => "d"}

      iex> Yamlixir.decode!("---\na: b\nc: d\n---\ne: f\ng: h", at: -1)
      %{"e" => "f", "g" => "h"}

      iex> Yamlixir.decode!("---\na: b\nc: d\n---\ne: f\ng: h", at: -1, keys: :atoms)
      %{e: "f", g: "h"}

  """
  @spec decode!(yaml, options) :: decoded
  def decode!(yaml, options \\ []) do
    case do_decode(yaml, options) do
      {:ok, decoded} -> decoded
      {:error, exception} -> raise exception
    end
  end

  @doc ~s"""
  Handles the sigil `~y` for decoding YAML.

  It passes the string to `decode!/2`, returning the decoded data. Raises a
  `Yamlixir.DecodingError` exception when given invalid YAML.

  ## Modifiers

    * `a`: keys are converted to atoms using `String.to_existing_atom/1`

  ## Examples

      iex> ~y\"\"\"
      ...> a: b
      ...> c: d
      ...> \"\"\"
      [%{"a" => "b", "c" => "d"}]

      iex> ~y\"\"\"
      ...> a: b
      ...> c: d
      ...> \"\"\"a
      [%{a: "b", c: "d"}]

  """
  @spec sigil_y(yaml, list) :: decoded
  def sigil_y(yaml, []), do: decode!(yaml)
  def sigil_y(yaml, [?a]), do: decode!(yaml, keys: :atoms!)

  @spec do_decode(yaml, options) :: {:ok, decoded} | {:error, error}
  defp do_decode(yaml, options) do
    options = Keyword.merge(options, @default_options)

    decoded =
      yaml
      |> :yamerl_constr.string(options)
      |> Yamlixir.YamerlParser.parse(options)
      |> at(options[:at])

    {:ok, decoded}
  catch
    {:yamerl_exception, [{_, _, message, _, _, :no_matching_anchor, _, _}]} ->
      {:error, %Yamlixir.DecodingError{message: List.to_string(message)}}

    _, _ ->
      {:error, %Yamlixir.DecodingError{}}
  end

  defp at(decoded, at) when is_integer(at), do: Enum.at(decoded, at)
  defp at(decoded, nil), do: decoded
  defp at(_decoded, _), do: raise(ArgumentError, "value given to option `:at` must be an integer")
end
