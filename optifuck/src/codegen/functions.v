module codegen
import math
import strconv

pub fn gen_line(line string) {
	set_ptr(ctx.allocated + 1)
	//mut sorted := utils.sort_letters(line)
	mut last := i8(0)
	/*
	This code can optimize printing of long lines by pregenerating most used
	letters, but not always usable so disabled for now

	if sorted.len > 2 {
		write(sorted[0]); left(); write(sorted[1])
		left(); write(sorted[2]); left(); sorted = sorted[0..3]
		for c in line {
			if sorted.contains(c.ascii_str()) {
					 if sorted[0] == c {set_ptr(allocated + 4)}
				else if sorted[1] == c {set_ptr(allocated + 3)}
				else if sorted[2] == c {set_ptr(allocated + 2)}
				show(); continue
			}
			set_ptr(allocated + 1)
			if math.abs(last - c) < 30 {if last > c {ctx.bf_code += '-'.repeat(math.abs(last - c))}
			else if c > last {ctx.bf_code += '+'.repeat(math.abs(last - c))} show()}
			else {nullify(); write(c); show()} last = c 
		}
	}*/
	for i := 0; i < line.len; i++ {
		mut c := i8(line[i]); 
		if i + 1 <line.len && line[i].ascii_str() == '\\' &&
		line[i + 1].ascii_str() == 'n' {c = 10;}
		if math.abs(i16(last) - i16(c)) < 30 {
			if last > c {ctx.bf_code += '-'.repeat(math.abs(last - c))}
			else if c > last {ctx.bf_code += '+'.repeat(math.abs(last - c))} 
			show()
		}
		else {write(u8(c)); show()} 
		last = c 
		if c == 10 {i++; continue}
	}
	set_ptr(ctx.allocated+1); nullify()
}

pub fn get_val(s string) {
	if s.is_int() {write(u8(strconv.atoi(s) or {0}))}
	else if is_var(s) {start := ctx.ptr; set_ptr(ctx.variables[s]); copy_to(start)}
	else {nullify()}
}

pub fn add_cell(adr u32) {
	start := ctx.ptr; set_ptr(adr); copy_to_custom_buffer(start, ctx.vars_created);
	set_ptr(start);
}

//OPERATORS. Example x = x - y: put ptr to x, pass address of y
pub fn substract(adr u32) {
	alc := ctx.allocated //MAY CAUSE BUGS. If so, do + 1
	start := ctx.ptr; move_to(alc + 3); //put x to (3)

	set_ptr(adr);
	begin(); minus(); set_ptr(alc); plus(); set_ptr(alc + 4); plus(); right(); plus();
	set_ptr(adr); end(); set_ptr(alc); move_to(adr); //fast copy y to (4) and (5)
	
	set_ptr(alc + 5); invert(); begin(); minus(); set_ptr(alc + 3);
	move_to(alc + 2); set_ptr(alc + 5); end(); //if y is 0 - return x (3)

    set_ptr(alc + 3); begin(); //if x > 0
	
	set_ptr(alc + 4); copy_to_custom_buffer(alc + 5, alc + 2); 
	begin(); nullify(); left(); minus(); right(); end(); //and (4) > 0 then x--
	set_ptr(alc + 5); minus(); //and y--
	
	copy_to_custom_buffer(alc + 4, alc + 2); // if y = 0 return x
	set_ptr(alc + 4); invert(); 
	begin(); minus(); set_ptr(alc + 3); move_to(alc + 2); set_ptr(alc + 4); 
	end(); 
	
	set_ptr(alc + 5); move_to(alc + 4); set_ptr(alc + 3); end(); //returning
	set_ptr(alc + 4); nullify(); 
	set_ptr(alc + 2); move_to(start);
}

pub fn multiply(adr u32) {
	alc := ctx.allocated; start := ctx.ptr
	move_to(alc + 4); set_ptr(adr); copy_to_custom_buffer(alc + 5, ctx.vars_created); //x to (4) y to (5)
	set_ptr(alc + 5); begin(); minus(); //while y > 0
	set_ptr(alc + 4); begin(); minus(); left(); plus();
	left(); plus(); set_ptr(alc + 4); end(); //add x to (2) and move it to (3)
	
	left(); move_to(alc + 4); set_ptr(alc + 5); end(); //move (3) back to (4)
	set_ptr(alc + 2); move_to(start); set_ptr(alc + 4); nullify(); // return (2)
}

pub fn divide(adr u32) {
	alc := ctx.allocated; start := ctx.ptr; plus()
	move_to(alc + 3); set_ptr(adr); //copy_to(alc + 2);
	begin(); minus(); set_ptr(alc); plus(); right(); plus(); right(); 
	plus(); set_ptr(adr); end(); set_ptr(alc); move_to(adr); right();
	begin();
		set_ptr(alc + 3); begin();
			set_ptr(alc + 2); 
			begin(); 
				minus(); set_ptr(alc + 4); plus(); right(); plus()
				set_ptr(alc + 2); 
			end(); 
			set_ptr(alc + 5); move_to(alc + 2);
			set_ptr(alc + 4); 
			begin()
				right(); plus();
				set_ptr(alc + 3); minus();
				begin()
					set_ptr(alc + 5); nullify(); set_ptr(alc + 6); plus();
					set_ptr(alc + 3); minus();
				end()
				set_ptr(alc + 6); move_to(alc + 3);
				set_ptr(alc + 5); 
				begin()
					set_ptr(alc + 4);
					begin()
						set_ptr(start); minus()
						set_ptr(alc + 4); nullify(); 
					end(); plus()
					set_ptr(alc + 5); minus()
				end()
			set_ptr(alc + 4); minus(); end()
			set_ptr(start); plus()
		set_ptr(alc + 3); end();
	set_ptr(alc); nullify(); right(); nullify();
	right(); nullify(); end();
}

pub fn divide_by_const(num u8) {
	alc := ctx.allocated; start := ctx.ptr; plus(); move_to(alc + 3);
	set_ptr(alc); write_custom_buffer_no_null(num, alc + 1);
	begin(); minus(); right(); plus(); right(); plus(); left(); left();
	end(); right()
	begin();
		set_ptr(alc + 3); begin();
			set_ptr(alc + 2); 
			begin(); 
				minus(); set_ptr(alc + 4); plus(); right(); plus()
				set_ptr(alc + 2); 
			end(); 
			set_ptr(alc + 5); move_to(alc + 2);
			set_ptr(alc + 4); 
			begin()
				right(); plus();
				set_ptr(alc + 3); minus();
				begin()
					set_ptr(alc + 5); nullify(); set_ptr(alc + 6); plus();
					set_ptr(alc + 3); minus();
				end()
				set_ptr(alc + 6); move_to(alc + 3);
				set_ptr(alc + 5); 
				begin()
					set_ptr(alc + 4);
					begin()
						set_ptr(start); minus()
						set_ptr(alc + 4); nullify(); 
					end(); plus()
					set_ptr(alc + 5); minus()
				end()
			set_ptr(alc + 4); minus(); end()
			set_ptr(start); plus()
		set_ptr(alc + 3); end();
	set_ptr(alc); nullify(); right(); nullify();
	right(); nullify(); end();
}