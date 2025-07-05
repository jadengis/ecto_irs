# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EctoIRS is an Elixir library that provides easy auditing capabilities for Ecto schemas and migrations. The library allows developers to automatically track who created or modified database records.

## Architecture

The library consists of two main modules:

- **EctoIRS.Schema** (`lib/ecto_irs/schema.ex`): Provides macros for adding audit fields to Ecto schemas, including `audits/2` macro that generates `:inserted_by` and `:updated_by` fields with automatic population
- **EctoIRS.Migration** (`lib/ecto_irs/migration.ex`): Provides migration helpers for adding audit columns to database tables via the `audits/2` function

## Common Commands

### Testing
```bash
mix test
```

### Code Quality
```bash
mix credo          # Run static code analysis
mix dialyzer       # Run type checking (first run will take longer)
```

### Dependencies
```bash
mix deps.get       # Install dependencies
mix deps.compile   # Compile dependencies
```

### Documentation
```bash
mix docs           # Generate documentation
```

### Development
```bash
mix compile        # Compile the project
```

## Key Dependencies

- **Ecto**: Core database library (~> 3.10)
- **Ecto SQL**: SQL adapter for Ecto (~> 3.10)
- **Nimble Options**: Schema validation for options
- **Credo**: Static code analysis (dev/test only)
- **Dialyxir**: Type checking with Dialyzer (dev/test only)
- **ExDoc**: Documentation generation (dev only)