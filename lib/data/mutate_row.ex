defmodule Bigtable.MutateRow do
  @moduledoc """
  Provides functions to build `Google.Bigtable.V2.MutateRowRequest` and submit them to Bigtable.
  """
  alias Bigtable.Utils
  alias Google.Bigtable.V2
  alias V2.Bigtable.Stub
  alias V2.MutateRowsRequest.Entry

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowRequest` with a provided table name and `Google.Bigtable.V2.MutateRowsRequest.Entry`.
  """
  @spec build(V2.MutateRowsRequest.Entry.t(), binary()) :: V2.MutateRowRequest.t()
  def build(%Entry{} = row_mutations, table_name) when is_binary(table_name) do
    V2.MutateRowRequest.new(
      table_name: table_name,
      row_key: row_mutations.row_key,
      mutations: row_mutations.mutations
    )
  end

  @doc """
  Builds a `Google.Bigtable.V2.MutateRowRequest` with default table name and provided `Google.Bigtable.V2.MutateRowsRequest.Entry`.
  """
  @spec build(V2.MutateRowsRequest.Entry.t()) :: V2.MutateRowRequest.t()
  def build(%Entry{} = row_mutations) do
    build(row_mutations, Bigtable.Utils.configured_table_name())
  end

  @doc """
  Submits a `Google.Bigtable.V2.MutateRowRequest` given either a  `Google.Bigtable.V2.MutateRowsRequest.Entry` or a `Google.Bigtable.V2.MutateRowRequest`.

  Returns a `Google.Bigtable.V2.MutateRowResponse`
  """
  @spec mutate(V2.MutateRowRequest.t()) :: {:ok, V2.MutateRowResponse.t()} | {:error, binary()}
  def mutate(%V2.MutateRowRequest{} = request) do
    request
    |> Utils.process_request(&Stub.mutate_row/3, single: true)
  end

  @spec mutate(V2.MutateRowsRequest.Entry.t()) ::
          {:ok, V2.MutateRowResponse.t()} | {:error, binary()}
  def mutate(%Entry{} = row_mutations) do
    request = build(row_mutations)

    request
    |> mutate()
  end
end
