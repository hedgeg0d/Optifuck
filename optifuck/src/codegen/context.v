module codegen
import os

struct GenerationCtx {
mut:
	ptr				u32
	output_file		os.File
	allocated		u32
	ff_hints		bool
	optimizations	bool = true
	line_max_len	u16	 = 75
	variables		map[string]u32
	vars_created	u32
	legal_var_names	[]string
	bf_code			string
	used			[]u32
	used_type		[]u8
}

pub fn is_var(name string) bool {return ctx.variables.keys().contains(name)}

pub fn (ctx GenerationCtx) get_free_cell() u32 {
	mut i := u32(ctx.allocated + 7)
	for {
		if i in ctx.used {i++}
		else {return i}
	}
	return 0
}

pub fn (mut ctx GenerationCtx) mark_used(adr u32, type_ u8) {
	ctx.used << adr
	ctx.used_type << type_
}