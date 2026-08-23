# atlas-to-kysely

## Repository structure

```text
.github/workflows/  CI and FlakeHub publishing workflows
fixture/main/       Atlas schema fixture and generated TypeScript fixtures
generator.go        Atlas realm to Kysely TypeScript generation
loader.go           Atlas SQLite HCL parsing
mapper.go           Atlas-to-TypeScript type mapping
main.go             CLI flag parsing and file/stdout I/O
*_test.go           Unit and integration tests
Justfile            Formatting, lint, build, test, and CI recipes
flake.nix           Nix development shell, package, and overlay
package.nix         Nix package definition
go.mod              Go module metadata and dependencies
```

## Development commands

### Execution rules

- Run commands from the repository root.
- Enter the pinned toolchain with `nix develop` before running Just recipes when the required tools are not already installed.
- Use Just as the task runner; this is a standalone Go module and has no JavaScript workspace.
- Keep generated fixture output synchronized with generator behavior when changing serialization or naming rules.
- Check every returned error and wrap errors with `%w` when adding context.

### Standard tasks

- `nix develop` — Enter the Nix shell with Go, golangci-lint, and Just.
- `just fix` — Format Go code and apply supported golangci-lint fixes.
- `just check` — Verify formatting and run golangci-lint without changing files.
- `just build` — Build `build/atlas-to-kysely` from the current module.
- `just test` — Run all Go tests with the race detector.
- `just ci` — Run `check`, `build`, and `test` in sequence.
- `nix build --no-link` — Evaluate and build the installable `atlas-to-kysely` Nix package without retaining a result link.
- `nix flake check --all-systems --no-build` — Evaluate flake checks for every supported system without building packages.

### CLI documentation

The [README API section](./README.md#api) is the canonical end-user reference for CLI flags, output behavior, and failure cases. Keep both English and Japanese READMEs synchronized whenever that contract changes.

## Architecture

### CLI boundary

- `main.go` owns flag parsing, required-input handling, file reads, generation invocation, and stdout or output-file writes.
- The CLI accepts `--input`/`-i`, `--output`/`-o`, and `--camel-case`; keep the user-visible flags and README API reference synchronized.
- Output-file success diagnostics go to standard error so generated TypeScript remains clean on standard output when no output path is supplied.
- The module uses `package main`; `ParseHCLBytes`, `GenerateOptions`, and `GenerateKysely` are internal implementation helpers used by the CLI and tests, not a supported importable Go API.

### Atlas loading

- `loader.go` delegates HCL evaluation to `ariga.io/atlas/sql/sqlite.EvalHCLBytes` and rejects realms without schemas.
- Keep the parser database-free and preserve wrapped errors at this boundary.

### Type generation

- `mapper.go` owns Atlas-to-TypeScript type mapping, SQLite affinity fallback, nullability, and `Generated<T>` detection.
- `generator.go` owns identifier transformation, deterministic ordering, TypeScript key serialization, and `DB`/table interface rendering.
- Preserve compatibility with Kysely's default `CamelCasePlugin` transform and `kysely-codegen` output ordering when changing naming behavior.

### Validation fixtures

- `fixture/main/schema.hcl` is the representative Atlas input.
- `fixture/main/generated.camel.ts.fixture` and `fixture/main/generated.snake.ts.fixture` lock the two identifier modes and generated-column import behavior.
- Unit tests cover conversion helpers and parser errors; `generator_integration_test.go` covers end-to-end realm-to-TypeScript generation.

## Development tools

- **Go 1.24**: Builds and tests the CLI and generator package.
- **golangci-lint**: Formats Go code and runs repository lint checks.
- **Just**: Provides the standard task surface used locally and in CI.
- **Nix flakes**: Pin the development shell, package, and supported systems.
- **GitHub Actions**: Runs `just ci` and publishes main-branch flake revisions through FlakeHub.

## Package-specific rules

- Keep this repository as a standalone Go module; do not reintroduce Vite+, Bun, or JavaScript workspace configuration.
- Keep the module path `github.com/totto2727-org/atlas-to-kysely` and update `go.sum` with `go.mod` whenever dependencies change.
- Update both generated fixtures and the integration test when intentional output changes affect identifier transforms, sorting, type mapping, nullability, or generated columns.
- Run `just ci` after source or fixture changes; run the Nix evaluation commands when changing `flake.nix` or `package.nix`.
- Keep README end-user content in `README.md`; this file is the canonical developer and AI-agent operating guide.

_This AGENTS.md was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [AGENTS template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/agents/template.md)._
