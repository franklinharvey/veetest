# veetest — agent instructions

This repo is the **published V test harness** [veetest](https://github.com/franklinharvey/veetest). Consumers (e.g. [vrpc](https://github.com/franklinharvey/vrpc)) depend on a **git tag**, not a relative path.

## Commands

```bash
# Run self-tests (required before any release)
v -cc gcc test .

# Install this module locally from the repo root
v install

# Install a tagged release (what consumers use)
v install https://github.com/franklinharvey/veetest@v0.2.0
```

CI runs `v -cc gcc test .` on Ubuntu with `libgc-dev` and gcc.

## Project layout

| File | Purpose |
|------|---------|
| `suite.v` | `VeetestSuite`, `VeetestCase`, `run`, `suite`, `case` |
| `expect.v` | `check`, `eq_str`, `eq_int`, `contains`, `len_is` |
| `suite_test.v` | Harness self-tests |
| `v.mod` | Module manifest; bump `version` on release |

Public API lives in module `veetest`. Do not break names without a major version bump.

## Publishing a release (required after API or behavior changes)

When you change veetest in a way consumers should pick up:

1. **Run tests** — `v -cc gcc test .` must pass.
2. **Bump `version`** in `v.mod` (semver: patch for fixes, minor for additive API, major for breaks).
3. **Update `README.md`** — install snippet must show the new tag.
4. **Commit and push** to `main`.
5. **Create a git tag** matching the version with a `v` prefix:
   ```bash
   git tag v0.1.2
   git push origin v0.1.2
   ```
6. **Update consumers** — In repos that depend on veetest, change `v.mod` to the new URL, then run `v install`:
   ```v
   dependencies: ['https://github.com/franklinharvey/veetest@v0.1.2']
   ```
   Known consumer: `franklinharvey/vrpc` (`vrpc/v.mod`, `examples/users/v.mod`). Open a PR there if the bump is not automatic.

Do not rely on `github.com/franklinharvey/veetest@…` without the `https://` URL — V 0.5.1 resolves metadata correctly only with:

`https://github.com/franklinharvey/veetest@vX.Y.Z`

## Code conventions

- V **0.5.x** target; test entrypoints remain `fn test_*()` in `*_test.v` files.
- Prefer `!` errors from helpers over bare `assert` inside veetest cases (consumers follow this pattern).
- Handler receivers: avoid `(mut r &T)` — use `(r &T)` per V 0.5 rules.
- Function fields in structs: initialize with `= unsafe { nil }` or use `?fn` types.
- Error handling in `run()`: use `c.run() or { ... continue }`, not `if err := c.run()`.

## Boundaries

- Do not commit secrets or `.env` files.
- Do not remove or rename published symbols without a version bump and consumer updates.
- Do not add vrpc or other app code here — veetest stays a standalone module.
- Keep the module small; put experimental features behind clear names and update `TASKS.md`.

## Verification checklist before tagging

- [ ] `v -cc gcc test .` passes locally
- [ ] `v.mod` `version` matches the new tag (e.g. `0.1.2` ↔ `v0.1.2`)
- [ ] README install line uses the new tag
- [ ] Consumer `v.mod` files updated or a follow-up PR is noted for the user
