# atlas-to-kysely

Go 1.24 CLI that generates Kysely type definitions from Atlas schemas.

## Commands

- `vp run fix` formats and fixes Go code with golangci-lint.
- `vp run check` checks formatting and lint findings with golangci-lint.
- `vp run test` runs the Go tests with the race detector and shuffled order.
- `vp run build` builds `build/atlas-kysely-gen`.
- `nix build` builds the installable `atlas-to-kysely` package.

## Conventions

- Run commands from the repository root.
- Keep application-specific Nix settings in `package.nix`.
- Check every returned error and wrap errors with `%w` when adding context.
