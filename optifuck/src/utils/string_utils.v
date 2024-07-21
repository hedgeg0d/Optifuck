module utils

//sorts letters by usage
pub fn sort_letters(line string) string {
	mut checked := []u8{}
	mut freq	:= []u8{}
	for i := 0; i < line.len - 1; i++ {
		if line[i] in checked {continue}
		mut count := u8(1)
		for j := i + 1; j < line.len; j++ {
			if line[i] == line[j] {count++}
		}
		checked << line[i]
		freq	<< count
	}
	//sort
	mut variants := []u8{}
	for i in freq {if i !in variants {variants << i}}
	variants.sort(a > b)
	mut combined_arr := [][]u8{}
	for i := 0; i < freq.len; i++ {combined_arr << [checked[i], freq[i]]}
	unsafe {free(checked); free(freq)}
	mut newline := ''
	for i in variants {
		for element in combined_arr {
			if element[1] == i {newline += element[0].ascii_str()}
		}
	}
	return newline
}