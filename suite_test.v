module veetest

import os

struct MetaState {
mut:
	ran_setup     bool
	ran_teardown  bool
	ran_before    int
	ran_after     int
	ran_case      []string
}

fn test_runner() ! {
	mut st := &MetaState{}
	run(VeetestSuite{
		name: 'meta'
		setup: fn [mut st] () ! {
			st.ran_setup = true
		}
		teardown: fn [mut st] () ! {
			st.ran_teardown = true
		}
		cases: [
			case('passes', fn () ! {
				check(true, 'ok')!
			}),
			case('eq', fn () ! {
				eq_int('n', 2, 1 + 1)!
			}),
		],
	})!
	check(st.ran_setup, 'setup should run')!
	check(st.ran_teardown, 'teardown should run')!
}

fn test_runner_reports_failures() ! {
	run(suite('fail', [
		case('bad', fn () ! {
			return error('on purpose')
		}),
	])) or {
		contains('err', err.msg(), 'fail / bad')!
		return
	}
	return error('expected suite to fail')
}

struct FlagState {
mut:
	a bool
	b bool
}

fn test_skip_case() ! {
	mut st := &FlagState{}
	run(suite('skip-suite', [
		skip('ignored', fn [mut st] () ! {
			st.a = true
		}),
		case('runs', fn () ! {}),
	]))!
	check(!st.a, 'skipped case should not run')!
}

fn test_only_cases() ! {
	mut st := &FlagState{}
	run(suite('only-suite', [
		only('focused', fn [mut st] () ! {
			st.a = true
		}),
		case('other', fn [mut st] () ! {
			st.b = true
		}),
	]))!
	check(st.a, 'only case should run')!
	check(!st.b, 'non-only case should not run when only is set')!
}

fn test_filter_env() ! {
	os.setenv('VEETEST_FILTER', 'keep', true)
	defer {
		os.unsetenv('VEETEST_FILTER')
	}
	mut st := &FlagState{}
	run(suite('filter', [
		case('keep-me', fn [mut st] () ! {
			st.a = true
		}),
		case('drop-me', fn [mut st] () ! {
			st.b = true
		}),
	]))!
	check(st.a, 'filtered-in case should run')!
	check(!st.b, 'filtered-out case should not run')!
}

fn test_fail_fast() ! {
	mut st := &FlagState{}
	run(VeetestSuite{
		name:      'fast'
		fail_fast: true
		cases: [
			case('first-fail', fn () ! {
				return error('stop')
			}),
			case('second', fn [mut st] () ! {
				st.a = true
			}),
		],
	}) or {
		contains('err', err.msg(), 'first-fail')!
		check(!st.a, 'fail_fast should stop after first failure')!
		return
	}
	return error('expected suite to fail')
}

fn test_before_and_after_case() ! {
	mut st := &MetaState{}
	run(VeetestSuite{
		name: 'hooks'
		before_case: fn [mut st] () ! {
			st.ran_before++
		}
		after_case: fn [mut st] () ! {
			st.ran_after++
		}
		cases: [
			case('a', fn [mut st] () ! {
				st.ran_case << 'a'
			}),
			case('b', fn [mut st] () ! {
				st.ran_case << 'b'
			}),
		],
	})!
	eq_int('before', 2, st.ran_before)!
	eq_int('after', 2, st.ran_after)!
	eq_int('cases', 2, st.ran_case.len)!
}

struct TableState {
mut:
	seen []string
}

fn test_cases_table() ! {
	mut st := &TableState{}
	run(suite('table', cases_table('row', ['x', 'y'], fn [mut st] (name string) ! {
		st.seen << name
	})))!
	eq_int('seen', 2, st.seen.len)!
	check(st.seen.contains('x'), 'should run row x')!
	check(st.seen.contains('y'), 'should run row y')!
}

fn test_must_err_and_ok() ! {
	must_err('errs', fn () ! {
		return error('boom')
	})!
	must_ok('ok', fn () ! {})!
	must_err('no err', fn () ! {}) or {
		contains('msg', err.msg(), 'expected error')!
		return
	}
	return error('must_err should fail when no error')
}

fn test_approx_f64() ! {
	approx_f64('pi', 3.14, 3.1400001, 0.001)!
	approx_f64('bad', 1.0, 2.0, 0.01) or {
		contains('msg', err.msg(), 'want 1')!
		return
	}
	return error('approx_f64 should fail')
}

fn test_eq_str_diff_multiline() ! {
	eq_str_diff('file', 'line1\nline2\n', 'line1\nLINE2\n') or {
		contains('msg', err.msg(), 'line 2')!
		return
	}
	return error('expected multiline diff')
}
