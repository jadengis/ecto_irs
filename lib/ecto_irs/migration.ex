defmodule EctoIRS.Migration do
  @moduledoc """
  `Ecto.Migration` extensions for auditing capabilities.
  """
  import Ecto.Migration
  alias Ecto.Migration.Runner

  @opts_schema [
    inserted_by: [
      type: :atom,
      doc:
        "the prefix before `_id` of the foreign key column for auditing row insertion subjects."
    ],
    updated_by: [
      type: :atom,
      doc: "the prefix before `_id` of the foreign key column for audting row update subjects."
    ],
    null: [
      type: :boolean,
      default: false,
      doc:
        "determines whether the column accepts null values. When not specified, the database will use its default behaviour (which is to treat the column as nullable in most databases)."
    ]
  ]

  @doc """
  Adds `:inserted_by_id` and `:updated_by_id` audit columns.

  The `table` argument specifies the tables that audit columns reference.
  Audit columns are not null by default. This assumes that audited tables
  will always have their records inserted (and updated) by a valid subject
  in the application.

  Following options will override the repo configuration specified by
  `:migration_audits`.

  ## Options

  #{NimbleOptions.docs(@opts_schema)}

  As well as all `opts` supported by `references`.
  """
  @spec audits(atom(), Keyword.t()) :: nil
  def audits(table, opts \\ []) when is_list(opts) do
    opts = Keyword.merge(Runner.repo_config(:migration_audits, []), opts)

    {inserted_by, opts} = Keyword.pop(opts, :inserted_by, :inserted_by)
    {updated_by, opts} = Keyword.pop(opts, :updated_by, :updated_by)
    {null, opts} = Keyword.pop(opts, :null, false)

    if inserted_by != false, do: add(:"#{inserted_by}_id", references(table, opts), null: null)
    if updated_by != false, do: add(:"#{updated_by}_id", references(table, opts), null: null)
  end
end
