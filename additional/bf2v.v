module main

import os

fn main() {
	if os.args.len < 2 {
		println("No input given")
		return
	}
	if !os.args[1].ends_with('.b') {
		println('Wrong file format')
		return
	}
	lines := os.read_lines(os.args[1]) or {panic("Failed to read file")}
	bfchars := [">", "<", "+", "-", "[", "]", ".", ","]
	mut bfcode := ""
	for line in lines {
		for c in line {
			if c.ascii_str() in bfchars {
				bfcode += c.ascii_str()
			}
		}
	}
	mut filename := ''
	if os.args.len > 3 && "-o" in os.args {
		mut idx := 0
		for i, _ in os.args {if os.args[i] == "-o" && i + 1 < os.args.len {idx = i + 1}}
		if idx != 0 {filename = os.args[idx]}
		else {filename = os.args[1].split('.')[0]+".v"}
	}
	else {filename = os.args[1].split('.')[0]+".v"}
	os.rm(filename) or {print('')}
	mut out := os.open_append(filename) or {panic(err)}
	out.write_string("mut mem := [65536]u8{}\nmut ptr := u32(0)\n") or {print('')}
	mut tab_count, mut ptr_balance, mut balance, mut tabbed := 0, 0, 0, false
	for i in bfcode {
		c := i.ascii_str()
		if !tabbed {tabbed = true; for n := 0; n < tab_count; n++ {out.write_string("\t") or {print('')}}}
		if c != '>' && c != '<' && ptr_balance != 0 {
			out.write_string("ptr = ptr ${if ptr_balance > 0 {"+"} else {""}} ${ptr_balance}\n") or {print('')}
			ptr_balance = 0; tabbed = false
		}
		else if c != '-' && c != '+' && balance != 0 {
			out.write_string("mem[ptr] = mem[ptr] ${if balance > 0 {"+"} else {""}} ${balance}\n") or {print('')}
			balance = 0; tabbed = false
		}
		if !tabbed && c == ']' && tab_count > 0 {tab_count--}
		if !tabbed {tabbed = true; for n := 0; n < tab_count; n++ {out.write_string("\t") or {print('')}}}
		match c {
			'>' {ptr_balance++}
			'<'	{ptr_balance--}
			'+'	{balance++}
			'-'	{balance--}
			'.'	{out.write_string("eprint(mem[ptr].ascii_str())\n") or {print('')}; tabbed = false}
			',' {out.write_string("mem[ptr] = u8(os.input()[0])\n") or {print('')}; tabbed = false}
			'[' {out.write_string("for mem[ptr] > 0 {\n") or {print('')} tab_count++; tabbed = false}
			']' {out.write_string("}\n") or {print('')} tabbed = false}
			else {}
		}
	}
	if "-d" in os.args {
		out.write_string("println('')\nfor i := 0; i < 20; i++ {\n\tprint('\${mem[i]}\t')\n\tif i == 9 {println('')}\n}\n") or {print('')}	
	}
}