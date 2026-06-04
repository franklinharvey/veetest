// Core runner: suites, cases, setup/teardown. Built on V's `v test` entrypoints.
module veetest

import os
import time

pub type VeetestFn = fn () !

pub type VeetestSetupFn = fn () !

pub type VeetestTeardownFn = fn () !

pub struct VeetestCase {
pub:
	name string
	run  VeetestFn = unsafe { nil }
	skip bool
	only bool
}

pub struct VeetestSuite {
pub:
	name        string
	setup       ?VeetestSetupFn
	teardown    ?VeetestTeardownFn
	before_case ?VeetestFn
	after_case  ?VeetestFn
	fail_fast   bool
	cases       []VeetestCase
}

pub fn case(name string, run VeetestFn) VeetestCase {
	return VeetestCase{
		name: name
		run:  run
	}
}

pub fn skip(name string, run VeetestFn) VeetestCase {
	return VeetestCase{
		name: name
		run:  run
		skip: true
	}
}

pub fn only(name string, run VeetestFn) VeetestCase {
	return VeetestCase{
		name: name
		run:  run
		only: true
	}
}

pub fn suite(name string, cases []VeetestCase) VeetestSuite {
	return VeetestSuite{
		name:  name
		cases: cases
	}
}

fn filter_from_env() string {
	return os.getenv('VEETEST_FILTER')
}

fn should_run_case(c VeetestCase, filter string, only_mode bool) bool {
	if c.skip {
		return false
	}
	if only_mode && !c.only {
		return false
	}
	if filter != '' && !c.name.contains(filter) {
		return false
	}
	return true
}

fn count_runnable(cases []VeetestCase, filter string, only_mode bool) int {
	mut n := 0
	for c in cases {
		if should_run_case(c, filter, only_mode) {
			n++
		}
	}
	return n
}

pub fn run(s VeetestSuite) ! {
	filter := filter_from_env()
	rep := reporter_from_env()

	mut only_mode := false
	mut only_count := 0
	for c in s.cases {
		if c.only {
			only_mode = true
			only_count++
		}
	}
	if only_count > 1 {
		eprintln('veetest: warning: ${only_count} cases marked only')
	}

	runnable := count_runnable(s.cases, filter, only_mode)
	if runnable == 0 {
		eprintln('veetest: no cases to run in suite "${s.name}"')
		return
	}

	if setup := s.setup {
		setup() or {
			return error('suite "${s.name}" setup: ${err.msg()}')
		}
	}
	mut teardown_err := ''
	if td := s.teardown {
		defer {
			td() or {
				teardown_err = err.msg()
			}
		}
	}

	suite_header(rep, s.name)
	mut failures := []string{}
	mut tap_idx := 0

	for c in s.cases {
		if !should_run_case(c, filter, only_mode) {
			report_skip(rep, s.name, c.name)
			continue
		}

		if bc := s.before_case {
			bc() or {
				msg := 'suite "${s.name}" before_case: ${err.msg()}'
				tap_idx = report_case(rep, tap_idx, VeetestCaseReport{
					ok:        false
					suite:     s.name
					case_name: c.name
					ms:        0
					err_msg:   msg
				})
				failures << '${s.name} / ${c.name}: ${msg}'
				if s.fail_fast {
					break
				}
				continue
			}
		}

		mut after_err := ''
		if ac := s.after_case {
			defer {
				ac() or {
					after_err = err.msg()
				}
			}
		}

		t0 := time.now()
		c.run() or {
			ms := time.since(t0).milliseconds()
			msg := err.msg()
			tap_idx = report_case(rep, tap_idx, VeetestCaseReport{
				ok:        false
				suite:     s.name
				case_name: c.name
				ms:        ms
				err_msg:   msg
			})
			failures << '${s.name} / ${c.name}: ${msg}'
			if after_err != '' {
				return error('suite "${s.name}" after_case: ${after_err}')
			}
			if s.fail_fast {
				break
			}
			continue
		}
		ms := time.since(t0).milliseconds()
		tap_idx = report_case(rep, tap_idx, VeetestCaseReport{
			ok:        true
			suite:     s.name
			case_name: c.name
			ms:        ms
			err_msg:   ''
		})
		if after_err != '' {
			return error('suite "${s.name}" after_case: ${after_err}')
		}
	}

	if teardown_err != '' {
		return error('suite "${s.name}" teardown: ${teardown_err}')
	}
	if failures.len > 0 {
		return error('${failures.len} case(s) failed:\n${failures.join('\n')}')
	}
}
