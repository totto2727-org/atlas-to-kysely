set shell := ["bash", "-euo", "pipefail", "-c"]

default: ci

fix:
    golangci-lint fmt
    golangci-lint run --fix ./...

check:
    golangci-lint fmt --diff
    golangci-lint run ./...

build:
    mkdir -p build
    go build -o build/atlas-kysely-gen .

test:
    go test -race ./...

ci: check build test
