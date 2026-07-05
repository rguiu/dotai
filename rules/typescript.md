# TypeScript / JavaScript rules

- Use strict mode (`strict: true` in tsconfig.json). No implicit `any`.
- Prefer `interface` over `type` for object shapes, `type` for unions and primitives.
- Use `const` assertions (`as const`) for literal types and tuple narrowing.
- Avoid `enum` — use string unions (`'foo' | 'bar'`) with `as const` arrays.
- Async: prefer `async/await` over raw promises. Use `Promise.all` for parallel operations, not sequential awaits.
- Error handling: use `try/catch` with typed errors. Never swallow errors silently. Use `Result<T, E>` pattern from `neverthrow` or `ts-results` in library code.
- Testing: use `vitest` or `jest`. Prefer `describe`/`it` blocks. Mock at module boundaries, not internals.
- Linting: `eslint` with the project's config. Formatting: `prettier --check`.
- Null handling: use optional chaining (`?.`) and nullish coalescing (`??`). No `!` non-null assertions unless proven.
- Imports: use ESM syntax (`import`/`export`). Sort imports: external libs first, then internal modules.
- React: use functional components. Props as interfaces. Hooks at the top of components. No inline object/array literals in JSX props (they cause re-renders).
- Node.js: use `node:` prefix for built-in imports (`import fs from 'node:fs'`).
- No `console.log` in production code — use a proper logger. No `any` unless absolutely necessary (document why).
