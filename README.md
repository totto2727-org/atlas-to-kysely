# atlas-to-kysely

atlas-to-kysely generates Kysely-compatible TypeScript database interfaces from an Atlas SQLite `schema.hcl` file without connecting to a database or invoking the Atlas CLI.

## Usage

Run the installed command with an Atlas schema and write generated types to standard output:

```bash
atlas-to-kysely --input schema.hcl
```

Write the generated types to a file, or enable the optional Kysely camel-case transform:

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
atlas-to-kysely --input schema.hcl --camel-case
```

The repository fixture can be used for a complete local example:

```bash
go run . --input fixture/main/schema.hcl --output /tmp/types.ts
```

## Key features

- Parses Atlas SQLite HCL directly through `ariga.io/atlas`, so no database connection or Atlas CLI is required.
- Maps Atlas integer, float, decimal, string, binary, boolean, time, JSON, enum, and SQLite-affinity types to TypeScript types.
- Preserves nullable columns as `T | null` and wraps default or auto-increment columns with Kysely's `Generated<T>`.
- Supports identity output and Kysely's default `CamelCasePlugin` identifier transform through one boolean flag.
- Produces deterministic table, column, and database-interface ordering compatible with `kysely-codegen`.

## Prerequisites

- **Go 1.24 or later**: Required for `go run`, `go install`, or building from source.
- **Kysely**: Add `kysely` to the TypeScript project when generated columns use the `Generated<T>` wrapper.

## Setup

1. Install the command from the Go module.

```bash
go install github.com/totto2727-org/atlas-to-kysely@latest
```

2. Run the command from the directory containing your Atlas schema.

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
```

3. Alternatively, clone the repository and run it directly with Go.

```bash
git clone https://github.com/totto2727-org/atlas-to-kysely.git
cd atlas-to-kysely
go run . --input fixture/main/schema.hcl
```

## API

The supported interface is the `atlas-to-kysely` CLI. It reads an Atlas SQLite schema and writes Kysely-compatible TypeScript to standard output or an output file, with an optional camel-case transform. See the [complete CLI reference](./AGENTS.md#cli-reference) for flags, output behavior, and failure cases.

## Type mapping

| Atlas or SQLite type | TypeScript type |
| --- | --- |
| `int`, `integer`, or names containing `INT` | `number` |
| `real`, `float`, `double`, or names containing `REAL`, `FLOA`, or `DOUB` | `number` |
| `numeric`, `decimal`, or names containing `NUMERIC` or `DECIMAL` | `number` |
| `text`, `char`, `clob`, or names containing `TEXT`, `CHAR`, or `CLOB` | `string` |
| `boolean`, `bool` | `boolean` |
| `blob` or an empty SQLite type name | `Uint8Array` |
| `date`, `datetime`, `timestamp` | `string` |
| `json`, `jsonb` | `string` |
| `enum("a", "b")` | `"a" \| "b"` |
| `null = true` | `T \| null` |
| Default value or `auto_increment` | `Generated<T>` |

## Development

For repository structure, development commands, and contributor guidance, see [AGENTS.md](./AGENTS.md).

## License

No license file is currently included in this repository.

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
