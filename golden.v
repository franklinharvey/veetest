module veetest

import os

pub fn golden(label string, got string, golden_path string) ! {
	if os.getenv('UPDATE_GOLDEN') == '1' {
		os.write_file(golden_path, got) or {
			return error('${label}: write golden ${golden_path}: ${err.msg()}')
		}
		eprintln('veetest: updated golden ${golden_path}')
		return
	}
	want := os.read_file(golden_path) or {
		return error('${label}: read golden ${golden_path}: ${err.msg()}')
	}
	eq_str_diff(label, want, got)!
}

pub fn eq_file(label string, got_path string, want_path string) ! {
	got := os.read_file(got_path) or {
		return error('${label}: read ${got_path}: ${err.msg()}')
	}
	if os.getenv('UPDATE_GOLDEN') == '1' {
		os.write_file(want_path, got) or {
			return error('${label}: write golden ${want_path}: ${err.msg()}')
		}
		eprintln('veetest: updated golden ${want_path}')
		return
	}
	want := os.read_file(want_path) or {
		return error('${label}: read ${want_path}: ${err.msg()}')
	}
	eq_str_diff(label, want, got)!
}
