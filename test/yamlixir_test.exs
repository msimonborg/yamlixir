defmodule YamlixirTest do
  use ExUnit.Case, async: true
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

  defp fixture(file) do
    File.read!(File.cwd!() <> "/test/fixtures/#{file}.yml")
  end
end
