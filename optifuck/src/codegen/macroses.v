module codegen
import utils

pub fn show() 	{ctx.bf_code += '.'}
pub fn input() 	{ctx.bf_code += ','}
pub fn begin() 	{ctx.bf_code += '['}
pub fn end() 	{ctx.bf_code += ']'}
pub fn plus() 	{ctx.bf_code += '+'}
pub fn minus() 	{ctx.bf_code += '-'}

pub fn right() {
	ctx.bf_code += '>' 
	ctx.ptr++
}

pub fn left() {
	ctx.bf_code += '<'
	ctx.ptr--
}

pub fn set_ptr(pos u32) {
	if ctx.ptr < pos {ctx.bf_code += ">".repeat(pos - ctx.ptr)}
	else if ctx.ptr > pos {ctx.bf_code += "<".repeat(ctx.ptr - pos)}
	ctx.ptr = pos
}

pub fn nullify() {ctx.bf_code += "[-]"}

pub fn add(num u8) {ctx.bf_code += "+".repeat(num)}

pub fn write(num u8) {
	nullify(); if num < 12 {ctx.bf_code += "+".repeat(num)}
	else {
		start := ctx.ptr
		mut first, mut second := utils.find_pair(num)
		if first != 0 && second != 0 {
			set_ptr(ctx.allocated); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(ctx.allocated); end(); set_ptr(start)
		} else {
			first, second = utils.find_pair(num-1)
			set_ptr(ctx.allocated); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(ctx.allocated); end(); set_ptr(start); plus()
		}
	}
}

pub fn write_no_null(num u8) {
	if num < 12 {ctx.bf_code += "+".repeat(num)}
	else {
		start := ctx.ptr
		mut first, mut second := utils.find_pair(num)
		if first != 0 && second != 0 {
			set_ptr(ctx.allocated); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(ctx.allocated); end(); set_ptr(start)
		} else {
			first, second = utils.find_pair(num-1)
			set_ptr(ctx.allocated); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(ctx.allocated); end(); set_ptr(start); plus()
		}
	}
}

//default buffer is the end of allocated zone (allocated value)
pub fn write_custom_buffer(num u8, buffer u32) {
	nullify(); if num < 12 {ctx.bf_code += "+".repeat(num)}
	else {
		start := ctx.ptr
		mut first, mut second := utils.find_pair(num)
		if first != 0 && second != 0 {
			set_ptr(buffer); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(buffer); end(); set_ptr(start)
		} else {
			first, second = utils.find_pair(num-1)
			set_ptr(buffer); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(buffer); end(); set_ptr(start); plus()
		}
	}
}

pub fn write_custom_buffer_no_null(num u8, buffer u32) {
	if num < 12 {ctx.bf_code += "+".repeat(num)}
	else {
		start := ctx.ptr
		mut first, mut second := utils.find_pair(num)
		if first != 0 && second != 0 {
			set_ptr(buffer); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(buffer); end(); set_ptr(start)
		} else {
			first, second = utils.find_pair(num-1)
			set_ptr(buffer); add(u8(first))
			begin(); minus(); set_ptr(start); add(u8(second));
			set_ptr(buffer); end(); set_ptr(start); plus()
		}
	}
}

pub fn move_to(adr u32) {
	if adr == ctx.ptr{return}
	start := ctx.ptr; begin(); minus(); set_ptr(adr); plus(); set_ptr(start); end();
}

pub fn copy_to(adr u32) {
	if adr == ctx.ptr {return}
	start := ctx.ptr; begin(); minus(); 
	set_ptr(ctx.allocated); plus(); set_ptr(adr); plus();
	set_ptr(start); end(); set_ptr(ctx.allocated); move_to(start); set_ptr(start);
}

pub fn copy_to_custom_buffer(adr u32, buffer u32) {
	start := ctx.ptr; begin(); minus(); 
	set_ptr(buffer); plus(); set_ptr(adr); plus();
	set_ptr(start); end(); set_ptr(buffer); move_to(start); set_ptr(start);
}

pub fn invert() {
	start := ctx.ptr; set_ptr(ctx.allocated); plus(); set_ptr(start);
	begin(); nullify(); set_ptr(ctx.allocated); minus(); set_ptr(start);
	end(); set_ptr(ctx.allocated); begin(); minus(); set_ptr(start);
	plus(); set_ptr(ctx.allocated); end(); set_ptr(start);
}