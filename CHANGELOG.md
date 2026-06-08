# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-04

### Added

- `VEETEST_FILTER` environment variable for substring case filtering
- TAP and JSON reporters via `VEETEST_REPORTER`, with per-case timing in human output
- `skip` and `only` case helpers
- Golden file helpers (`golden`, `eq_file`) with `UPDATE_GOLDEN` and line diff output
- `must_err`, `must_ok`, `approx_f64`, and `fail_fast`
- `before_case` / `after_case` per-case hooks
- `cases_table` for table-driven cases
- Parallelism policy documentation in README

## [0.1.1] - 2026-06-04

### Fixed

- Document URL-style `v.mod` dependency (`https://github.com/...`) for V 0.5.x metadata resolution
- Add `repo_url` to `v.mod`

## [0.1.0] - 2026-06-04

### Added

- Initial release: `VeetestSuite` / `VeetestCase`, `run`, `suite`, `case`
- Setup and teardown hooks
- Expect helpers: `check`, `eq_str`, `eq_int`, `contains`, `len_is`
- Self-tests in `suite_test.v`

[0.2.0]: https://github.com/franklinharvey/veetest/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/franklinharvey/veetest/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/franklinharvey/veetest/releases/tag/v0.1.0
