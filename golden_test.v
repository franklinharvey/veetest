module veetest

import os

fn test_golden_match() ! {
	dir := os.dir(@FILE)
	golden_path := os.join_path(dir, 'testdata/sample.golden')
	got := 'hello\nworld\n'
	golden('sample', got, golden_path)!
}

fn test_golden_mismatch() ! {
	dir := os.dir(@FILE)
	golden_path := os.join_path(dir, 'testdata/sample.golden')
	golden('sample', 'wrong\n', golden_path) or {
		contains('msg', err.msg(), 'diff')!
		return
	}
	return error('expected golden mismatch')
}

fn test_eq_file() ! {
	dir := os.dir(@FILE)
	golden_path := os.join_path(dir, 'testdata/sample.golden')
	tmp := os.join_path(os.temp_dir(), 'veetest_eq_file_${os.getpid()}.txt')
	defer {
		os.rm(tmp) or {}
	}
	os.write_file(tmp, 'hello\nworld\n')!
	eq_file('tmp', tmp, golden_path)!
}
