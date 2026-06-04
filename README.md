# veetest

Named **suites** and **cases** for [V](https://vlang.io), on top of the built-in `v test` runner. V’s testing story is minimal (`test_*` functions and `assert`); veetest is meant to grow into a fuller harness over time.

Published as a V module:

```bash
v install https://github.com/franklinharvey/veetest@v0.1.0
```

Add to your `v.mod`:

```v
Module {
  dependencies: ['https://github.com/franklinharvey/veetest@v0.1.0']
}
```

## Usage

Each `_test.v` file still exposes `test_*` functions for `v test`. Inside them, run a suite:

```v
import veetest

fn test_validation() ! {
	veetest.run(veetest.suite('validation', [
		veetest.case('email', fn () ! {
			veetest.len_is('errors', errs, 1)!
		}),
	]))!
}
```

### Setup / teardown

```v
veetest.run(veetest.VeetestSuite{
	name: 'http'
	setup: start_server
	teardown: stop_server
	cases: [ ... ],
})!
```

### Expect helpers

`veetest.check`, `veetest.eq_str`, `veetest.eq_int`, `veetest.contains`, `veetest.len_is` — return `!` errors with labels.

## Commands

```bash
cd veetest && v -cc gcc test .
```

## Roadmap

See [TASKS.md](TASKS.md). Agents: see [AGENTS.md](AGENTS.md) for release and consumer bump workflow.
