module veetest

import json
import os

enum VeetestReporter {
	human
	tap
	json
}

struct VeetestCaseReport {
	ok        bool
	suite     string
	case_name string
	ms        i64
	err_msg   string
}

struct VeetestJsonLine {
	suite     string @[json: suite]
	case_name string @[json: case]
	ok        bool   @[json: ok]
	ms        i64    @[json: ms]
	err_msg   string @[json: err]
}

fn reporter_from_env() VeetestReporter {
	match os.getenv('VEETEST_REPORTER') {
		'tap' { return .tap }
		'json' { return .json }
		else { return .human }
	}
}

fn suite_header(rep VeetestReporter, suite_name string) {
	if rep == .human {
		println('Suite: ${suite_name}')
	}
}

fn report_case(rep VeetestReporter, tap_idx int, r VeetestCaseReport) int {
	match rep {
		.human {
			if r.ok {
				println('  ${r.case_name} ... ok (${r.ms}ms)')
			} else {
				println('  ${r.case_name} ... FAIL (${r.ms}ms)')
				eprintln('    ${r.err_msg}')
			}
		}
		.tap {
			idx := tap_idx + 1
			if r.ok {
				println('ok ${idx} - ${r.suite} / ${r.case_name}')
			} else {
				println('not ok ${idx} - ${r.suite} / ${r.case_name} # ${r.err_msg}')
			}
			return idx
		}
		.json {
			line := json.encode(VeetestJsonLine{
				suite:     r.suite
				case_name: r.case_name
				ok:        r.ok
				ms:        r.ms
				err_msg:   r.err_msg
			})
			println(line)
		}
	}
	return tap_idx
}

fn report_skip(rep VeetestReporter, suite_name string, case_name string) {
	if rep == .human {
		println('  ${case_name} ... skip')
	}
}
