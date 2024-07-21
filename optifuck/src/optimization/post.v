module optimization

pub fn optimize_bf(code string) string {
	mut optimized := optimize_nullify(code)
	optimized = optimize_pointer(optimized)
	return optimized
}

pub fn optimize_pointer(code string) string {
	mut optimized := ""; mut ptr_balance := i32(0)
	for c in code {
			 if c.ascii_str() == '>' {ptr_balance++}
		else if c.ascii_str() == '<' {ptr_balance--}
		else {
				 if ptr_balance > 0 {optimized += '>'.repeat(ptr_balance)}
			else if ptr_balance < 0 {optimized += '<'.repeat(ptr_balance * -1)}
			ptr_balance = 0; optimized += c.ascii_str()
		}
	}
	return optimized
}

pub fn optimize_nullify(code string) string {
	if code.len < 3 {return code}
	mut optimized := ''; mut has_plus := false; mut duplicate := false;
	for i := u32(0); i < code.len; i++ {
		c := code[i].ascii_str() if c == '+' {has_plus = true}
		if code.len > i + 2 {
			if code[i..i + 3] == '[-]' {
				if i > 1 && code[i - 1].ascii_str() == ']' {i += 2; continue}
				if !has_plus {i += 2; continue}
				else {
					if !duplicate {optimized += code[i..i + 3]; i += 2; duplicate = true; continue}
					else {i += 2; continue}
				}
			}
			duplicate = false
		}
		optimized += c
	}
	return optimized
}