# Go rules

- Error handling: always check errors. Never use `_` to discard them unless intentionally ignoring a documented safe-to-ignore return. Wrap errors with context: `fmt.Errorf("doing X: %w", err)`.
- Use standard library first — `net/http` over frameworks, `database/sql` over ORMs. Only reach for external libraries when stdlib is insufficient.
- Project layout: follow `cmd/`, `internal/`, `pkg/` conventions. `internal/` for code not importable by other modules.
- Testing: use table-driven tests. Test files in the same package (`_test.go`). Use `go test -race` for concurrent code.
- Concurrency: prefer channels for communication, mutexes for state protection. Use `context.Context` for cancellation and timeouts. Never start a goroutine without a way to stop it.
- Interfaces: define them where they're consumed, not where they're implemented. Keep them small (1-3 methods). Follow the `io.Reader`/`io.Writer` pattern.
- Naming: use short, clear names. `c` for a cursor, `i` for an index, `err` for errors. Descriptive names for exported symbols. Avoid `get` prefix for getters.
- Linting: `go vet` and `golangci-lint run`. Formatting: `gofmt` or `goimports`.
- Use `defer` for cleanup. Order matters — defer after error checks, not before.
- No panics in library code. Use `log.Fatal` only in `main`. Return errors instead.
- Package naming: lowercase, no underscores, no plurals unless it's a collection package. `package user`, not `package users`.
- Zero-value initialization: use `var x Type` instead of `x := new(Type)` when zero value is useful.
