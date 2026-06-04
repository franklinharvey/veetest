module veetest

pub type VeetestTableFn = fn (string) !

pub fn cases_table(prefix string, rows []string, row_fn VeetestTableFn) []VeetestCase {
	mut out := []VeetestCase{cap: rows.len}
	for row in rows {
		row_name := row
		out << VeetestCase{
			name: '${prefix}/${row_name}'
			run: fn [row_name, row_fn] () ! {
				row_fn(row_name)!
			}
		}
	}
	return out
}
