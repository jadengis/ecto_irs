defmodule EctoIRS.SchemaTest do
  use ExUnit.Case, async: true

  defmodule Schema do
    use Ecto.Schema

    schema "schema" do
      field(:name, :string)
    end
  end

  defmodule AltSchema do
    use Ecto.Schema

    @primary_key false
    schema "alt_schema" do
      field(:alt_id, :id, primary_key: true)
      field(:name, :string)
    end
  end

  defmodule Audits do
    use Ecto.Schema
    use EctoIRS.Schema

    schema "audits" do
      field(:name, :string)
      audits(Schema)
    end
  end

  test "audits default fields" do
    assert Audits.__schema__(:fields) == [
             :id,
             :name,
             :inserted_by_id,
             :updated_by_id
           ]

    assert %Ecto.Association.BelongsTo{} = Audits.__schema__(:association, :inserted_by)
    assert %Ecto.Association.BelongsTo{} = Audits.__schema__(:association, :updated_by)
  end

  test "audits don't autogenerate by default" do
    assert Audits.__schema__(:autogenerate) == []
    assert Audits.__schema__(:autoupdate) == []
  end

  defmodule AuditsCustom do
    use Ecto.Schema
    use EctoIRS.Schema

    schema "audits" do
      audits(Schema,
        inserted_by: :created_by,
        updated_by: :modified_by,
        autogenerate: {Foo, :bar, []}
      )
    end
  end

  test "audits with alternate names" do
    assert AuditsCustom.__schema__(:fields) == [
             :id,
             :created_by_id,
             :modified_by_id
           ]

    assert %Ecto.Association.BelongsTo{} = AuditsCustom.__schema__(:association, :created_by)
    assert %Ecto.Association.BelongsTo{} = AuditsCustom.__schema__(:association, :modified_by)
  end

  test "audits autogenerate metadata (private) when configured to do so" do
    assert AuditsCustom.__schema__(:autogenerate) == [
             {[:created_by_id, :modified_by_id], {Foo, :bar, []}}
           ]

    assert AuditsCustom.__schema__(:autoupdate) == [
             {[:modified_by_id], {Foo, :bar, []}}
           ]
  end

  defmodule AuditsFalse do
    use Ecto.Schema
    use EctoIRS.Schema

    schema "audits" do
      audits(Schema, inserted_by: false, updated_by: false)
    end
  end

  test "audits set to false" do
    assert AuditsFalse.__schema__(:fields) == [:id]
    assert AuditsFalse.__schema__(:autogenerate) == []
    assert AuditsFalse.__schema__(:autoupdate) == []
  end

  defmodule AuditsOptions do
    use Ecto.Schema
    use EctoIRS.Schema

    schema "audits" do
      audits(AltSchema, references: :alt_id)
    end
  end

  test "audits options" do
    assert inserted_by = AuditsOptions.__schema__(:association, :inserted_by)
    assert updated_by = AuditsOptions.__schema__(:association, :updated_by)
    assert inserted_by.related_key == :alt_id
    assert updated_by.related_key == :alt_id
  end
end
