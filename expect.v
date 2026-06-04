module veetest

pub fn check(ok bool, msg string) ! {
	if !ok {
		return error(msg)
	}
}

pub fn eq_str(label string, want string, got string) ! {
	eq_str_diff(label, want, got)!
}

pub fn eq_str_diff(label string, want string, got string) ! {
	if want == got {
		return
	}
	mut msg := '${label}: strings differ'
	if hint := first_line_diff(want, got) {
		msg += ' (${hint})'
	} else if want.len > 80 || got.len > 80 {
		msg += ' (want len ${want.len}, got len ${got.len})'
	} else {
		msg += ': want "${want}", got "${got}"'
	}
	return error(msg)
}

pub fn eq_int(label string, want int, got int) ! {
	if want != got {
		return error('${label}: want ${want}, got ${got}')
	}
}

pub fn contains(label string, haystack string, needle string) ! {
	if !haystack.contains(needle) {
		return error('${label}: expected to contain "${needle}"')
	}
}

pub fn len_is[T](label string, got []T, want int) ! {
	if got.len != want {
		return error('${label}: want len ${want}, got ${got.len}')
	}
}

pub fn approx_f64(label string, want f64, got f64, epsilon f64) ! {
	diff := if want > got { want - got } else { got - want }
	if diff > epsilon {
		return error('${label}: want ${want}, got ${got} (epsilon ${epsilon})')
	}
}

pub fn must_err(label string, body fn () !) ! {
	body() or {
		return
	}
	return error('${label}: expected error')
}

pub fn must_ok(label string, body fn () !) ! {
	body() or {
		return error('${label}: ${err.msg()}')
	}
}

fn first_line_diff(want string, got string) ?string {
	want_lines := want.split('\n')
	got_lines := got.split('\n')
	limit := if want_lines.len < got_lines.len { want_lines.len } else { got_lines.len }
	for i in 0 .. limit {
		if want_lines[i] != got_lines[i] {
			return 'first diff at line ${i + 1}: want "${want_lines[i]}", got "${got_lines[i]}"'
		}
	}
	if want_lines.len != got_lines.len {
		return 'line count: want ${want_lines.len}, got ${got_lines.len}'
	}
	return none
}
