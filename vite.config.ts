import { defineConfig } from 'vite-plus'

export default defineConfig({
  run: {
    tasks: {
      build: {
        command: 'mkdir -p build && go build -o build/atlas-kysely-gen .',
      },
      check: {
        command: 'golangci-lint fmt --diff && golangci-lint run ./...',
      },
      fix: {
        command: 'golangci-lint fmt && golangci-lint run --fix ./...',
      },
      test: {
        command: 'go test -race -shuffle=on -count=1 ./...',
      },
    },
  },
})
