defmodule CheckAndMutateRowTest do
  @moduledoc false
  alias Bigtable.{CheckAndMutateRow, ChunkReader, MutateRow, Mutations, ReadRows, RowFilter}
  alias ChunkReader.ReadCell

  use ExUnit.Case

  doctest CheckAndMutateRow

  setup do
    assert ReadRows.read() == {:ok, %{}}

    row_key = "Test#123"
    qualifier = "column"

    {:ok, _} =
      Mutations.build(row_key)
      |> Mutations.set_cell("cf1", qualifier, "value", 0)
      |> MutateRow.build()
      |> MutateRow.mutate()

    on_exit(fn ->
      mutation = Mutations.build(row_key) |> Mutations.delete_from_row()

      mutation |> MutateRow.mutate()
    end)

    [
      qualifier: qualifier,
      row_key: row_key
    ]
  end

  describe "CheckAndMutateRow.mutate/2" do
    test "should apply a single true mutation when no predicate set and row exists", context do
      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.if_true(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "truthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should apply a multiple true mutation when no predicate set and row exists", context do
      mutation1 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      mutation2 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "alsoTruthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.if_true([mutation1, mutation2])
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "truthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "alsoTruthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should not apply a true mutation when no predicate set and row does not exist",
         context do
      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build("Doesnt#Exist")
        |> CheckAndMutateRow.if_true(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should apply a single true mutation when predicate true", context do
      filter = RowFilter.column_qualifier_regex(context.qualifier)

      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_true(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "truthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should apply a multiple true mutation when predicate true", context do
      filter = RowFilter.column_qualifier_regex(context.qualifier)

      mutation1 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      mutation2 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "alsoTruthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_true([mutation1, mutation2])
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "truthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "alsoTruthy"},
               row_key: context.row_key,
               timestamp: 0,
               value: "true"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should not apply a true mutation when predicate is false", context do
      filter = RowFilter.column_qualifier_regex("doesntexist")

      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "truthy", "true", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_true(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should apply a single false mutation when predicate false", context do
      filter = RowFilter.column_qualifier_regex("doesntexist")

      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "false", "false", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_false(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "false"},
               row_key: context.row_key,
               timestamp: 0,
               value: "false"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should apply multiple false mutations when predicate false", context do
      filter = RowFilter.column_qualifier_regex("doesntexist")

      mutation1 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "false", "false", 0)

      mutation2 =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "false2", "false2", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_false([mutation1, mutation2])
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "false2"},
               row_key: context.row_key,
               timestamp: 0,
               value: "false2"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: "false"},
               row_key: context.row_key,
               timestamp: 0,
               value: "false"
             },
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end

    test "should not apply a false mutation when predicate is true", context do
      filter = RowFilter.column_qualifier_regex(context.qualifier)

      mutation =
        Mutations.build(context.row_key) |> Mutations.set_cell("cf1", "false", "false", 0)

      {:ok, _result} =
        CheckAndMutateRow.build(context.row_key)
        |> CheckAndMutateRow.predicate(filter)
        |> CheckAndMutateRow.if_false(mutation)
        |> CheckAndMutateRow.mutate()

      expected =
        {:ok,
         %{
           context.row_key => [
             %ReadCell{
               family_name: %Google.Protobuf.StringValue{value: "cf1"},
               label: "",
               qualifier: %Google.Protobuf.BytesValue{value: context.qualifier},
               row_key: context.row_key,
               timestamp: 0,
               value: "value"
             }
           ]
         }}

      assert ReadRows.read() == expected
    end
  end
end
