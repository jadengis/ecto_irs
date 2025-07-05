# EctoIRS

[![Hex.pm](https://img.shields.io/hexpm/v/ecto_irs.svg)](https://hex.pm/packages/ecto_irs)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/ecto_irs)

EctoIRS is an Elixir library that provides easy auditing capabilities for Ecto schemas and migrations. The library allows developers to automatically track who created or modified database records.

## Features

- 🔍 **Automatic Audit Fields**: Automatically add `inserted_by` and `updated_by` fields to your schemas
- 🗃️ **Migration Helpers**: Easy-to-use migration functions for adding audit columns
- ⚙️ **Flexible Configuration**: Customize field names, references, and behavior
- 🚀 **Auto-population**: Support for automatic field population via MFA tuples
- 📦 **Zero Dependencies**: Built on top of Ecto with minimal external dependencies

## Installation

Add `ecto_irs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_irs, "~> 0.1.0"}
  ]
end
```

## Quick Start

### 1. Add Audit Columns to Your Database

In your migration:

```elixir
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
```

### 2. Add Audit Fields to Your Schema

In your schema:

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    field :content, :text
    
    # Generates :inserted_by and :updated_by associations
    audits MyApp.User
    
    timestamps()
  end
end
```

### 3. Query with Audit Information

```elixir
# Preload audit associations
post = MyApp.Repo.get(MyApp.Post, 1) |> MyApp.Repo.preload([:inserted_by, :updated_by])

# Access audit information
IO.puts "Created by: #{post.inserted_by.name}"
IO.puts "Last updated by: #{post.updated_by.name}"
```

## Schema Usage

### Basic Usage

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    audits MyApp.User
    timestamps()
  end
end
```

### Custom Field Names

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    
    audits MyApp.User,
      inserted_by: :created_by,
      updated_by: :modified_by
  end
end
```

### Disable Specific Fields

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    
    # Only track who created, not who updated
    audits MyApp.User, updated_by: false
  end
end
```

### Custom References

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    
    audits MyApp.User, references: :user_id
  end
end
```

### Automatic Field Population

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  schema "posts" do
    field :title, :string
    
    audits MyApp.User, autogenerate: {MyApp.Context, :current_user_id, []}
  end
end
```

### Pre-configuration

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use EctoIRS.Schema

  @audits_opts [autogenerate: {MyApp.Context, :current_user_id, []}]

  schema "posts" do
    field :title, :string
    audits MyApp.User
  end
end
```

## Migration Usage

### Basic Migration

```elixir
defmodule MyApp.Repo.Migrations.CreatePosts do
  use Ecto.Migration
  import EctoIRS.Migration

  def change do
    create table(:posts) do
      add :title, :string
      audits :users
      timestamps()
    end
  end
end
```

### Custom Column Names

```elixir
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
```

### Nullable Columns

```elixir
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
```

### Adding to Existing Tables

```elixir
defmodule MyApp.Repo.Migrations.AddAuditsToExistingTable do
  use Ecto.Migration
  import EctoIRS.Migration

  def change do
    alter table(:existing_posts) do
      audits :users
    end
  end
end
```

### Custom Reference Options

```elixir
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
```

## Configuration

### Repository Configuration

Configure default audit options at the repository level:

```elixir
config :my_app, MyApp.Repo,
  migration_audits: [
    inserted_by: :created_by,
    updated_by: :modified_by,
    null: false
  ]
```

### Schema Configuration Options

- `inserted_by`: The field name for insertion audit (default: `:inserted_by`)
- `updated_by`: The field name for update audit (default: `:updated_by`)
- `references`: The field on the referenced table (default: `:id`)
- `autogenerate`: MFA tuple for automatic field population

### Migration Configuration Options

- `inserted_by`: Column name prefix for insertion audit (default: `:inserted_by`)
- `updated_by`: Column name prefix for update audit (default: `:updated_by`)
- `null`: Whether columns accept null values (default: `false`)

## Best Practices

### 1. Add Indexes for Performance

```elixir
create index(:posts, [:inserted_by_id])
create index(:posts, [:updated_by_id])
```

### 2. Use Consistent Naming

Stick to either the default names or establish a consistent naming convention across your application.

### 3. Consider Nullable Columns

Decide whether audit fields should be required based on your application's security requirements.

### 4. Preload Associations

Always preload audit associations when you need to access the audit information:

```elixir
posts = MyApp.Repo.all(MyApp.Post) |> MyApp.Repo.preload([:inserted_by, :updated_by])
```

## Development

### Running Tests

```bash
mix test
```

### Code Quality

```bash
mix credo          # Run static code analysis
mix dialyzer       # Run type checking
```

### Documentation

```bash
mix docs           # Generate documentation
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

