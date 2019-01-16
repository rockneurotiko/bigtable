defmodule Bigtable.Connection.Auth do
  @scopes [
    "https://www.googleapis.com/auth/bigtable.data",
    "https://www.googleapis.com/auth/bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-bigtable.data",
    "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/cloud-platform.read-only",
    "https://www.googleapis.com/auth/bigtable.admin",
    "https://www.googleapis.com/auth/bigtable.admin.cluster",
    "https://www.googleapis.com/auth/bigtable.admin.instance",
    "https://www.googleapis.com/auth/bigtable.admin.table",
    "https://www.googleapis.com/auth/cloud-bigtable.admin",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
    "https://www.googleapis.com/auth/cloud-bigtable.admin.table"
  ]
  def get_token() do
    {:ok, token} =
      @scopes
      |> Enum.join(" ")
      |> Goth.Token.for_scope()

    token
  end
end