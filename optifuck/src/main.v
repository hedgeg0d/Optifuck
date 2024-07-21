module main
import os
import parser
import codegen

fn main() {
	args := os.args
	if args.len < 2 {
		println("No input given. Exiting...")
		return
	}
	//println("Args: ")
	//println(args)
	if !os.exists(args[1]) {
		println("File " + args[1] + " doens't exist!")
		return
	}
	if !args[1].ends_with(".optf") {
		println(args[1] + "is not Optifuck file!")
		return
	}
	output := args[1].split(".")[0] + ".b"
	os.create(output) or {
        println('Failed to create file ' + output + ': $err')
        return
    }
	input := os.read_file(args[1]) or {
        println('Failed to read file: $err')
        return
    }
	optimize := !args.contains('-O0')
	code, allocated, vars := parser.get_actual_code(input)
	unsafe {free(input); free(args)}
	codegen.generate(code, allocated, output, optimize, vars)
	return
}
