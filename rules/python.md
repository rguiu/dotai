# Python rules

- Use `pathlib.Path` for all filesystem operations, never `os.path` or string paths.
- All public functions must have type annotations. Use `collections.abc` generics (`Iterable`, `Sequence`, `Mapping`), not `typing.List`/`Dict` (3.9+).
- Prefer `dataclasses.dataclass` over raw dicts for structured data. Use `field(default_factory=...)` for mutable defaults.
- Use `pytest` for testing. Fixtures over setup/teardown. Parametrize over copy-paste.
- Error handling: raise specific exceptions. Never bare `except:`. Use `except SomeError as e:` and re-raise with `raise ... from e` to preserve stack traces.
- Async: use `asyncio` with `anyio` or `trio` for structured concurrency when available. Avoid mixing `asyncio` and threads.
- Dependencies: `pip-compile` or `uv` for lockfiles. Pin to exact versions in production.
- Linting: `ruff check && ruff format --check`. Type checking: `mypy --strict` (or project's configured level).
- Docstrings: Google-style for public APIs. Single-line for obvious internals.
- Context managers: use `with` for resource management. Custom context managers via `contextlib.contextmanager` or `__enter__`/`__exit__`.
- No mutable default arguments. No `if x == True`, use `if x`.
- Prefer `logging` over `print`. Use module-level loggers: `logger = logging.getLogger(__name__)`.
