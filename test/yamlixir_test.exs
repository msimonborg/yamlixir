defmodule YamlixirTest do
  use ExUnit.Case, async: true
  import Yamlixir, only: [sigil_y: 2]
  doctest Yamlixir

  test "decode/2 should decode blank yaml" do
    yaml = fixture("blank")
    assert {:ok, []} = Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode blank yaml" do
    yaml = fixture("blank")
    assert [] == Yamlixir.decode!(yaml)
  end

  test "decode/2 should decode empty yaml" do
    yaml = fixture("empty")
    assert {:ok, [%{}]} = Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode empty yaml" do
    yaml = fixture("empty")
    assert [%{}] == Yamlixir.decode!(yaml)
  end

  test "decode/2 should decode flat yaml" do
    yaml = fixture("flat")

    assert {:ok,
            [
              %{
                "a" => "a",
                "b" => 1,
                "c" => true,
                "d" => nil,
                "e" => [],
                ":f" => ":atom",
                "g" => 88.0
              }
            ]} == Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode flat yaml" do
    yaml = fixture("flat")

    assert [
             %{
               "a" => "a",
               "b" => 1,
               "c" => true,
               "d" => nil,
               "e" => [],
               ":f" => ":atom",
               "g" => 88.0
             }
           ] == Yamlixir.decode!(yaml)
  end

  test "decode/2 should decode nested yaml" do
    yaml = fixture("nested")

    assert {:ok,
            [
              %{
                "dev" => %{"foo" => "bar"},
                "prod" => %{"foo" => "foo"},
                "test" => %{"foo" => "baz"}
              }
            ]} == Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode nested yaml" do
    yaml = fixture("nested")

    assert [
             %{
               "dev" => %{"foo" => "bar"},
               "prod" => %{"foo" => "foo"},
               "test" => %{"foo" => "baz"}
             }
           ] == Yamlixir.decode!(yaml)
  end

  test "decode/2 option `keys: :atoms` converts map keys to atoms" do
    yaml = fixture("nested")

    assert {:ok,
            [
              %{
                dev: %{foo: "bar"},
                prod: %{foo: "foo"},
                test: %{foo: "baz"}
              }
            ]} == Yamlixir.decode(yaml, keys: :atoms)
  end

  test "decode!/2 option `keys: :atoms` converts map keys to atoms" do
    yaml = fixture("nested")

    assert [
             %{
               dev: %{foo: "bar"},
               prod: %{foo: "foo"},
               test: %{foo: "baz"}
             }
           ] == Yamlixir.decode!(yaml, keys: :atoms)
  end

  test "decode/2 should decode yaml with multiple documents" do
    yaml = fixture("multi")

    assert {:ok,
            [
              %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
              %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
            ]} == Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode yaml with multiple documents" do
    yaml = fixture("multi")

    assert [
             %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
             %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
           ] == Yamlixir.decode!(yaml)
  end

  test "decode/2 option `:at` returns a single document at the correct position" do
    yaml = fixture("multi")

    assert {:ok, %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}} ==
             Yamlixir.decode(yaml, at: -1)

    assert {:ok, %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []}} ==
             Yamlixir.decode(yaml, at: 0)
  end

  test "decode!/2 option `:at` returns a single document at the correct position" do
    yaml = fixture("multi")

    assert %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []} ==
             Yamlixir.decode!(yaml, at: -1)

    assert %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []} ==
             Yamlixir.decode!(yaml, at: 0)
  end

  test "decode/2 should decode yaml with multiple empty documents" do
    yaml = fixture("multi_empty")
    assert {:ok, [%{}, %{}, %{}]} == Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode yaml with multiple empty documents" do
    yaml = fixture("multi_empty")
    assert [%{}, %{}, %{}] == Yamlixir.decode!(yaml)
  end

  test "decode/2 should decode yaml with mapping between sequences" do
    yaml = fixture("mapping")

    assert {:ok, [%{["a", "b"] => [1, 2], ["c", "d"] => [3, 4], ["e"] => 5}]} ==
             Yamlixir.decode(yaml)
  end

  test "decode!/2 should decode yaml with mapping between sequences" do
    yaml = fixture("mapping")

    assert [%{["a", "b"] => [1, 2], ["c", "d"] => [3, 4], ["e"] => 5}] ==
             Yamlixir.decode!(yaml)
  end

  test "decode/2 decodes yaml with arrays" do
    yaml = fixture("arrays")
    assert {:ok, [["a", "b", %{"c" => ["d", "e"]}]]} == Yamlixir.decode(yaml)
  end

  test "decode!/2 decodes yaml with arrays" do
    yaml = fixture("arrays")
    assert [["a", "b", %{"c" => ["d", "e"]}]] == Yamlixir.decode!(yaml)
  end

  test "decode/2 should get error tuple for invalid yaml" do
    yaml = "*invalid"
    message = ~s(No anchor corresponds to alias "invalid")
    assert {:error, %Yamlixir.DecodingError{message: ^message}} = Yamlixir.decode(yaml)
  end

  test "decode!/2 should raise exception for invalid yaml" do
    yaml = "*invalid"

    assert_raise Yamlixir.DecodingError, ~s(No anchor corresponds to alias "invalid"), fn ->
      Yamlixir.decode!(yaml)
    end
  end

  test "sigil_y/2 decodes yaml" do
    yaml = ~y"""
    a: A
    b: 1
    """

    assert [%{"a" => "A", "b" => 1}] == yaml
  end

  test "sigil_y/2 accepts `:atoms` option" do
    yaml = ~y"""
    a: A
    b: 1
    """a

    assert [%{a: "A", b: 1}] == yaml
  end

  test "sigil_y/2 raises an exception with invalid yaml" do
    assert_raise Yamlixir.DecodingError, "decoding error", fn ->
      ~y":"
    end
  end

  defp fixture(file) do
    File.read!(File.cwd!() <> "/test/fixtures/#{file}.yml")
  end
end
