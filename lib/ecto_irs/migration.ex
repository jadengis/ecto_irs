defmodule EctoIRS.Migration do
  @moduledoc """
  `Ecto.Migration` extensions for auditing capabilities.

  This module provides the `audits/2` function for adding audit columns to your
  database tables during migrations. It automatically creates foreign key
  references to track who inserted or updated records.

  ## Usage

  Use the `audits/2` function in your migrations to add audit columns:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            add :content, :text
            
            # Adds :inserted_by_id and :updated_by_id columns
            audits :users
            
            timestamps()
          end
        end
      end

  This will create two foreign key columns:
  - `:inserted_by_id` - references the user who created the record
  - `:updated_by_id` - references the user who last updated the record

  Both columns are created as NOT NULL by default, assuming that all
  audited operations will have a valid user context.

  ## Custom Column Names

  You can customize the column names using the `:inserted_by` and `:updated_by`
  options:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            
            audits :users,
              inserted_by: :created_by,
              updated_by: :modified_by
            
            timestamps()
          end
        end
      end

  This creates `:created_by_id` and `:modified_by_id` columns instead.

  ## Nullable Columns

  By default, audit columns are NOT NULL. To make them nullable, use the
  `:null` option:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            
            audits :users, null: true
            
            timestamps()
          end
        end
      end

  ## Disabling Columns

  You can disable either column by setting it to `false`:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            
            # Only track who created, not who updated
            audits :users, updated_by: false
            
            timestamps()
          end
        end
      end

  ## Custom Reference Options

  You can pass additional options that will be forwarded to the `references/2`
  function:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            
            audits :users,
              column: :user_id,
              on_delete: :nilify_all,
              on_update: :update_all
            
            timestamps()
          end
        end
      end

  ## Adding Audit Columns to Existing Tables

  You can add audit columns to existing tables:

      defmodule MyApp.Repo.Migrations.AddAuditsToExistingTable do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          alter table(:existing_posts) do
            audits :users
          end
        end
      end

  ## Repository Configuration

  You can configure default audit options at the repository level using the
  `:migration_audits` configuration key:

      config :my_app, MyApp.Repo,
        migration_audits: [
          inserted_by: :created_by,
          updated_by: :modified_by,
          null: false
        ]

  These defaults will be applied to all `audits/2` calls, but can be overridden
  on a per-migration basis.

  ## Index Recommendations

  Consider adding indexes on audit columns for better query performance:

      defmodule MyApp.Repo.Migrations.CreatePosts do
        use Ecto.Migration
        import EctoIRS.Migration

        def change do
          create table(:posts) do
            add :title, :string
            audits :users
            timestamps()
          end

          create index(:posts, [:inserted_by_id])
          create index(:posts, [:updated_by_id])
        end
      end
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
