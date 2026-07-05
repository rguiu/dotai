# Rust rules

- Prefer `Result<T, E>` over panics. Use `anyhow` for application code, `thiserror` for library crates.
- Never `unwrap()` or `expect()` in production code paths. Use `?` operator or explicit match.
- Derive traits explicitly: `#[derive(Debug, Clone, PartialEq, Eq)]` as needed.
- Use `cargo clippy -- -D warnings` for linting. Zero warnings is the goal.
- Use `cargo fmt --check` for formatting. Configure `rustfmt.toml` per project conventions.
- Testing: unit tests in the same file (`#[cfg(test)] mod tests`). Integration tests in `tests/`. Use `cargo test` to run.
- Doc tests: use them for API examples. They serve as both documentation and tests.
- Error handling: use `Result` with meaningful error types. Avoid `Box<dyn Error>` in library code — use a concrete enum instead.
- Async: use `tokio` as the runtime unless the project specifies otherwise.
- Memory: prefer stack allocation. Use `&str` over `String` for parameters. Use `Cow<str>` when ownership is conditional.
- Generics: prefer `impl Trait` in argument position, explicit generics when the type is used multiple times.
- No `clone()` without a reason. If you're cloning, document why.
- Cargo.toml: sort dependencies alphabetically. Separate dev-dependencies and build-dependencies.
