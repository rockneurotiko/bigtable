defmodule Bigtable.MutateRows do
  alias Google.Bigtable.V2
  alias Bigtable.Connection

  @doc """
  Builds a MutateRows request with a provided table name
  """
  def build(table_name, entries) when is_binary(table_name) do
    V2.MutateRowsRequest.new(
      table_name: table_name,
      entries: entries
    )
  end

  @doc """
  Builds a MutateRows request with default table name if none provided
  """
  def build(entries) do
    build(Bigtable.Request.table_name(), entries)
  end

  def mutate(%V2.MutateRowsRequest{} = request) do
    Connection.get_connection()
    |> Bigtable.Stub.mutate_rows(request)
  end
end