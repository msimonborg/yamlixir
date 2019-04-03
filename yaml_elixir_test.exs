defmodule YamlElixirTest do
  use ExUnit.Case

  test "should parse blank file" do
    assert_parse_file("blank", %{})
  end

  test "should parse empty file" do
    assert_parse_file("empty", %{})
  end

  test "should parse flat file" do
    assert_parse_file("flat", %{
      "a" => "a",
      "b" => 1,
      "c" => true,
      "d" => nil,
      "e" => [],
      ":f" => ":atom",
      "g" => 88.0
    })
  end

  test "should parse flat file with atoms option" do
    assert_parse_file(
      "flat",
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => [], :f => :atom, "g" => 88.0},
      atoms: true
    )
  end

  test "should parse nested file" do
    assert_parse_file("nested", %{
      "dev" => %{"foo" => "bar"},
      "prod" => %{"foo" => "foo"},
      "test" => %{"foo" => "baz"}
    })
  end

  test "should parse file with multiple documents" do
    assert_parse_multi_file("multi", [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ])
  end

  test "should parse file with multiple empty documents" do
    assert_parse_multi_file("multi_empty", [%{}, %{}, %{}])
  end

  test "should parse blank string" do
    assert_parse_string("", %{})
  end

  test "should parse flat string" do
    yaml = """
      a: a
      b: 1
      c: true
      d: ~
      e: nil
      f: 1.2
    """

    assert_parse_string(yaml, %{
      "a" => "a",
      "b" => 1,
      "c" => true,
      "d" => nil,
      "e" => "nil",
      "f" => 1.2
    })
  end

  test "should parse nested string" do
    yaml = """
      prod:
        foo: foo
      dev:
        foo: bar
      test:
        foo: baz
    """

    assert_parse_string(yaml, %{
      "prod" => %{"foo" => "foo"},
      "dev" => %{"foo" => "bar"},
      "test" => %{"foo" => "baz"}
    })
  end

  test "should parse string with multiple documents" do
    yaml = """
    ---

    a: a
    b: 1
    c: true
    d: ~
    e: []

    ---

    z: z
    x: 1
    y: true
    w: ~
    v: []
    """

    assert_parse_multi_string(yaml, [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ])
  end

  test "should parse string with mapping between sequences" do
    yaml = """
    ---
    ?
      - a
      - b
    :
      - 1
      - 2
    ? [c, d]
    : [3, 4]
    ? [e]
    : 5
    """

    assert_parse_string(yaml, %{["a", "b"] => [1, 2], ["c", "d"] => [3, 4], ["e"] => 5})
  end

  test "map list without atom" do
    import YamlElixir.Sigil

    yaml = """
    ---
    list:
      - a: 1
      - b: 2
      - c: 3
      - d: 4
    """

    assert_parse_string(yaml, %{"list" => [%{"a" => 1}, %{"b" => 2}, %{"c" => 3}, %{"d" => 4}]})
  end

  test "sigil list atom" do
    import YamlElixir.Sigil

    yaml = ~y"""
    ---
    list:
      - :a: 1
      - :b: 2
      - :c: 3
      - :d: 4
    """a

    assert %{"list" => [a: 1, b: 2, c: 1, d: 4]} == yaml
  end

  test "sigil should parse string document" do
    import YamlElixir.Sigil

    yaml = ~y"""
    a: A
    b: 1
    """

    assert %{"a" => "A", "b" => 1} == yaml
  end

  test "sigil with atom keys option" do
    import YamlElixir.Sigil

    yaml = ~y"""
    a: :A
    :b: 1
    """a

    assert %{"a" => :A, b: 1} == yaml
  end

  test "should get error tuple for invalid literal" do
    yaml = "*invalid"

    assert {:error, "malformed yaml"} = YamlElixir.read_all_from_string(yaml)
    assert {:error, "malformed yaml"} = YamlElixir.read_from_string(yaml)
  end

  test "should get error tuple for invalid file" do
    path = test_data("invalid")

    assert {:error, "malformed yaml"} = YamlElixir.read_all_from_file(path)
    assert {:error, "malformed yaml"} = YamlElixir.read_from_file(path)
  end

  test "should receive keyword list when used `maps_as_keywords` option" do
    assert_parse_file(
      "nested",
      [{"test", [{"foo", "baz"}]}, {"dev", [{"foo", "bar"}]}, {"prod", [{"foo", "foo"}]}],
      maps_as_keywords: true
    )
  end

  test "should receive keyword list of keyword lists when used `maps_as_keywords` option and parsing nested map" do
    assert_parse_file(
      "nested_map",
      [{"prod", [{"test", [{"foo", "baz"}]}, {"dev", [{"foo", "bar"}]}, {"foo", "foo"}]}],
      maps_as_keywords: true
    )
  end

  defp test_data(file_name), do: Path.join(File.cwd!(), "test/fixtures/#{file_name}.yml")

  defp assert_parse_multi_file(file_name, result, options \\ []) do
    path = test_data(file_name)

    assert YamlElixir.read_all_from_file!(path, options) == result
  end

  defp assert_parse_file(file_name, result, options \\ []) do
    path = test_data(file_name)

    assert YamlElixir.read_from_file!(path, options) == result
  end

  defp assert_parse_multi_string(string, result, options \\ []) do
    assert YamlElixir.read_all_from_string!(string, options) == result
  end

  defp assert_parse_string(string, result, options \\ []) do
    assert YamlElixir.read_from_string!(string, options) == result
  end
end
