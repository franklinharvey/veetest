# Contributing

Thanks for helping improve veetest.

## Development setup

```bash
git clone https://github.com/franklinharvey/veetest.git
cd veetest
v install
```

On Linux CI and many local setups you also need a C toolchain and Boehm GC:

```bash
# Debian/Ubuntu
sudo apt-get install -y build-essential libgc-dev
```

## Running tests

```bash
v -cc gcc test .
```

Focused runs while developing:

```bash
VEETEST_FILTER=email v -cc gcc test .
UPDATE_GOLDEN=1 v -cc gcc test .
```

All changes should keep this passing before you open a pull request.

## Pull requests

1. Keep the diff focused — veetest is intentionally small.
2. Run `v -cc gcc test .` locally.
3. Add or update self-tests in `*_test.v` when behavior changes.
4. Prefer `!` errors from helpers over bare `assert` inside veetest cases.
5. Do not rename or remove published symbols without a major version bump.

If you change user-visible behavior or add API surface:

- Bump `version` in `v.mod` (semver).
- Add an entry to [CHANGELOG.md](CHANGELOG.md).
- Update the install pin in [README.md](README.md).

Release and tagging steps for maintainers are in [AGENTS.md](AGENTS.md).

## Reporting issues

Open a [GitHub issue](https://github.com/franklinharvey/veetest/issues) with:

- V version (`v version`)
- OS and compiler (`v -cc gcc` vs `v -cc clang`, etc.)
- Minimal reproduction or test snippet
- Expected vs actual output

## Scope

veetest is a thin layer on top of `v test`. Features that belong in application code, mocking libraries, or separate modules are usually out of scope — see README “Out of scope” and [TASKS.md](TASKS.md).
