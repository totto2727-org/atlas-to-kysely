# atlas-to-kysely

Go 1.24 CLI that generates Kysely type definitions from Atlas schemas.

## Commands

- `just fix` formats and fixes Go code with golangci-lint.
- `just check` checks formatting and lint findings with golangci-lint.
- `just test` runs the Go tests with the race detector.
- `just build` builds `build/atlas-kysely-gen`.
- `just ci` runs check, build, and test.
- `nix build` builds the installable `atlas-to-kysely` package.

## Conventions

- Run commands from the repository root.
- Use Just as the task runner; this repository has no JavaScript workspace.
- Keep application-specific Nix settings in `package.nix`.
- Check every returned error and wrap errors with `%w` when adding context.
