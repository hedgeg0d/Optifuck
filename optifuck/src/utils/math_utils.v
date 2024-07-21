module utils

import math
import strconv 

pub fn find_pair(n int) (int, int) {
	sqrtn := int(math.sqrt(n))
	for i := sqrtn; i >= 2; i-- {
		if n % i == 0 {return i32(i), i32(n / i)}
	}
	return 0, 0
}

pub fn atoi(num string) u8 {return u8(strconv.atoi(num) or {0})}