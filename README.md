# atlas-to-kysely

atlas-to-kysely generates Kysely-compatible TypeScript database interfaces from an Atlas SQLite `schema.hcl` file without connecting to a database or invoking the Atlas CLI.

## Usage

Save an Atlas SQLite schema as `schema.hcl`:

```hcl
schema "main" {}

table "users" {
  schema = schema.main
  column "id" {
    type           = integer
    null           = false
    auto_increment = true
  }
  column "display_name" {
    type = text
    null = true
  }
}
```

Generate Kysely-compatible TypeScript from the schema:

```bash
go run github.com/totto2727-org/atlas-to-kysely@latest --input schema.hcl
```

The same command is available through Nix:

```bash
nix run 'github:totto2727-org/atlas-to-kysely' -- --input schema.hcl
```

Installed command:

```bash
atlas-to-kysely --input schema.hcl
```

The standard output includes these Kysely-compatible types:

```typescript
import type { Generated } from "kysely";

export interface Users {
  display_name: string | null;
  id: Generated<number>;
}

export interface DB {
  users: Users;
}
```

Write the generated types to a file, or enable the optional Kysely camel-case transform:

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
atlas-to-kysely --input schema.hcl --camel-case
```

The `--output` command creates or overwrites `src/db/types.ts` and reports the result to standard error, for example `Generated: src/db/types.ts  (3 table(s))` for a three-table schema.

## Key features

- Parses Atlas SQLite HCL directly through `ariga.io/atlas`, so no database connection or Atlas CLI is required.
- Maps Atlas integer, float, decimal, string, binary, boolean, time, JSON, enum, and SQLite-affinity types to TypeScript types.
- Preserves nullable columns as `T | null` and wraps default or auto-increment columns with Kysely's `Generated<T>`.
- Supports identity output and Kysely's default `CamelCasePlugin` identifier transform through one boolean flag.
- Produces deterministic table, column, and database-interface ordering compatible with `kysely-codegen`.

## Prerequisites

- **Go 1.24 or later**: Required only for the `go install` route.
- **Nix with flakes enabled**: Required only for the `nix run`, `nix profile add`, and consumer-flake routes.
- **Kysely**: Add `kysely` to the TypeScript project when generated columns use the `Generated<T>` wrapper.

## Setup

Choose one installation route.

### One-shot

```bash
go run github.com/totto2727-org/atlas-to-kysely@latest --help
```

```bash
nix run 'github:totto2727-org/atlas-to-kysely' -- --help
```

### Persistent installation

Go module:

```bash
go install github.com/totto2727-org/atlas-to-kysely@latest
```

Nix profile:

```bash
nix profile add 'github:totto2727-org/atlas-to-kysely#atlas-to-kysely'
```

Consumer `flake.nix`: This example creates a reusable package containing the CLI; replace `aarch64-darwin` with a supported target when needed.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    atlas-to-kysely.url = "github:totto2727-org/atlas-to-kysely";
  };

  outputs = { nixpkgs, atlas-to-kysely, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "schema-tools";
        paths = [ atlas-to-kysely.packages.${system}.atlas-to-kysely ];
      };
    };
}
```

## API

The supported interface is the `atlas-to-kysely` CLI. This repository is a `main` package and does not publish a supported importable Go API.

### Flags

| Flag | Default | Description |
| --- | --- | --- |
| `--input`, `-i` | required | Path to the Atlas `schema.hcl` file. |
| `--output`, `-o` | standard output | Path to the generated `.ts` file. |
| `--camel-case` | `false` | Apply Kysely's default `CamelCasePlugin` transform to table and column identifiers. |
| `--help` | — | Print usage and flag help, then exit successfully. |

### Output

Without `--output`, the command writes generated TypeScript to standard output. With `--output`, it writes the TypeScript file and reports `Generated: <path>  (<count> table(s))` to standard error. `--camel-case` transforms table and column identifiers; without it, identifiers are preserved.

### Failures

The command exits non-zero and writes an `Error:` message to standard error when the required input is missing, the input file cannot be read, the HCL is invalid or contains no schema, or the output file cannot be written. An unsupported flag exits non-zero after printing the flag error and usage.

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
