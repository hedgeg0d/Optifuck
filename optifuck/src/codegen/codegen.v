module codegen
import os
import optimization
import utils

__global( 
	ctx GenerationCtx
)

pub fn generate(code []string, allocated u32, of string, optimize bool, vars []string) {
	ctx.allocated = allocated
	ctx.output_file = os.open_append(of) or {return}
	ctx.optimizations = optimize
	ctx.legal_var_names = vars
	for line in code {
		if line.starts_with("print(") {
			gen_line(line[7..line.len-2])
		} else if line.starts_with("put(") {
			mut parts := line.split(',')
			parts[0] = parts[0][4..parts[0].len].trim(' ')
			parts[parts.len - 1] = parts[parts.len - 1][0..parts[parts.len - 1].len - 1].trim(' ')
			for i := 0; i < parts.len; i++ {
				parts[i] = parts[i].trim(' \t')
				if is_var(parts[i]) {
					set_ptr(ctx.variables[parts[i]])
					show()
				} else {
					eprintln("\nError on line: " + line +
					'\nVariable \'' + parts[i] + '\' do not exist\n')
					continue
				}
			}
		} else if line.starts_with("repeat(") {
			if !line.contains('{') {continue}
			adr := ctx.get_free_cell(); set_ptr(adr)
			get_val(line.split(' ')[0][7..line.split(' ')[0].len - 1])
			set_ptr(adr); ctx.mark_used(adr, 1); begin()
		} else if line.starts_with("if(") {
			if !line.contains('{') {continue}
			adr := ctx.get_free_cell(); set_ptr(adr)
			get_val(line.split(' ')[0][3..line.split(' ')[0].len - 1])
			set_ptr(adr); ctx.mark_used(adr, 2); begin()
		} else if line.starts_with("while(") {
			val := line.split(' ')[0][6..line.split(' ')[0].len - 1]
			if !is_var(val) {continue}
			adr := ctx.variables[val]
			set_ptr(adr); ctx.mark_used(adr, 0); begin()
		} else if line == '}' {
			set_ptr(ctx.used[ctx.used.len - 1])
			type_ := ctx.used_type[ctx.used_type.len - 1]
			match type_ {
				1 {minus()}
				2 {nullify()}
				else {}
			}
			end()
			ctx.used.delete_last()
			ctx.used_type.delete_last()
		}
		parts := line.split(' ')
		if parts[0] == 'cell' && parts.len > 1 {
			if ctx.legal_var_names.contains(parts[1]) {
				ctx.variables[parts[1]] = ctx.vars_created
				ctx.vars_created++
			
				if parts.len > 3 && parts[2] == '=' {
					if parts[3].is_int() {
						set_ptr(ctx.variables[parts[1]])
						write_custom_buffer_no_null(utils.atoi(parts[3]), ctx.vars_created)
					} else if is_var(parts[3]) {
						set_ptr(ctx.variables[parts[3]])
						copy_to_custom_buffer(ctx.variables[parts[1]], ctx.vars_created)
					}
				}
			}
		} else if is_var(parts[0]) {
			if parts.len == 3 {
				set_ptr(ctx.variables[parts[0]]); start := ctx.ptr; 
				//set_ptr(ctx.allocated + 2); get_val(parts[2])
				match parts[1] {
					"+=" {
						if is_var(parts[2]) {add_cell(ctx.variables[parts[2]])}
						else if parts[2].is_int() {
							write_custom_buffer_no_null(utils.atoi(parts[2]), ctx.vars_created)
						}
					}
					"-=" {
						if is_var(parts[2]) {substract(ctx.variables[parts[2]])}
						else if parts[2].is_int() {
							set_ptr(ctx.allocated + 1); write_no_null(utils.atoi(parts[2]))
							set_ptr(start); substract(ctx.allocated + 1)
							set_ptr(ctx.allocated + 1); nullify()
						}
					}
					"*=" {
						if is_var(parts[2]) {multiply(ctx.variables[parts[2]])}
						else if parts[2].is_int() {
							set_ptr(ctx.allocated + 1); write_no_null(utils.atoi(parts[2]))
							set_ptr(start); multiply(ctx.allocated + 1)
							set_ptr(ctx.allocated + 1); nullify()
						}
					}
					"/=" {
						if is_var(parts[2]) {divide(ctx.variables[parts[2]])}
						else if parts[2].is_int() {divide_by_const(utils.atoi(parts[2]))}
					}
					else {}
				} 
			}
			if parts[1] == '=' {
				if parts[2].is_int() {
					set_ptr(ctx.variables[parts[0]])
					write_custom_buffer(utils.atoi(parts[2]), ctx.vars_created)
				} else if is_var(parts[2]) {
					set_ptr(ctx.variables[parts[0]]); nullify()
					set_ptr(ctx.variables[parts[2]])
					copy_to_custom_buffer(ctx.variables[parts[0]], ctx.vars_created)
				}
			} 
		}
	}
	
	if ctx.optimizations {ctx.bf_code = optimization.optimize_bf(ctx.bf_code)}
	mut counter := u16(0)
	for c in ctx.bf_code {
		counter++
		ctx.output_file.write([c]) or {return}
		if counter == ctx.line_max_len {ctx.output_file.write_string('\n') or {return}; counter = 0}
	}
	unsafe {free(counter)}; ctx.bf_code = ''
	ctx.output_file.close()
}