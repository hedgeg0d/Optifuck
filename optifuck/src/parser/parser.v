module parser

pub fn contains_illegal_char(illegals []string, str string) bool {
	for i in illegals {
		if str.contains(i) {return true}
	} return false
}

pub fn get_actual_code(code string) ([]string, u32, []string) {
	mut alloc := u32(0)
	mut actual_code := []string{}
	keywords := ["cell"] //reserved keywords
	illegal_chars := [')', '(', '\'', ' ', u8(10).ascii_str()]
	mut vars := []string{}
	lines := code.split('\n')
	for line in lines {
		if line.starts_with("//") {continue}
		for part in line.split(';') {
			if part.starts_with("cell") {
				parts := part.split(' ')
				if parts.len > 1 {
					if parts[1].is_int() {
						eprintln("\nError on line: " + line +
						'\nVariable names can\'t be numbers\n')
						continue
					} else if keywords.contains(parts[1]) {
						eprintln("\nError on line: " + line +
						'\nIllegal variable name\n')
						continue
					} else if vars.contains(parts[1]) {
						eprintln("\nError on line: " + line +
						'\nThis variable was already created\n')
						continue
					} else if contains_illegal_char(illegal_chars, parts[1]) {
						eprintln("\nError on line: " + line +
						'\nVariable contains illegal character\n')
						continue
					} else {
						vars << parts[1];
						alloc++
					}
				}
			}
			if part != '' {actual_code << part.trim_left(" ")}
		}
	}
	//println(vars)
	println("Lines: "); println(actual_code)
	
	return actual_code, alloc, vars
}