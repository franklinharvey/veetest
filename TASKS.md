# veetest tasks

## MVP (done)

- [x] `VeetestSuite` / `VeetestCase` with named output
- [x] `run`, `suite`, `case`
- [x] Setup / teardown hooks
- [x] Expect helpers (`check`, `eq_*`, `contains`, `len_is`)
- [x] Self-tests in `suite_test.v`
- [x] Published; vrpc consumes `https://github.com/franklinharvey/veetest@v0.1.0`

## v0.2.0 (done)

- [x] `VEETEST_FILTER` env — substring match on case names
- [x] Optional TAP / JSON reporter (`VEETEST_REPORTER`) + per-case timing
- [x] `skip` / `only` case helpers
- [x] Parallel suite policy docs (README)
- [x] Golden / `eq_file` helper with `UPDATE_GOLDEN` and line diff output
- [x] `must_err`, `must_ok`, `approx_f64`, `fail_fast`
- [x] `before_case` / `after_case` hooks
- [x] `cases_table` for table-driven cases

## Later

- [ ] HTTP test client helpers (server fixture, retry)
- [ ] Benchmark-style cases with timing stats
- [ ] Integration with `testsuite_begin` / `testsuite_end`
- [ ] Regex filter for `VEETEST_FILTER`
- [ ] Case tags when V test runner supports them
