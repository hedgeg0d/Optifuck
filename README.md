# Optifuck
 **Optifuck** is a little programming language that compiles to [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck). It is not meant for some real purposes, it is a project made for fun.


## Compiling
Optifuck compiler is 100% written in [V(Vlang)](https://vlang.io/)! V  is a modern  and  promising high-performance  programming  language, an alternative to C. First of all you need it to be installed. Next, just compile the optifuck folder
```
cd Optifuck/optifuck && v -enable-globals .
```

## Using the compiler
After the compilation process the compiler executable will appear. Pass path to some Optifuck file to compile it
```
./optifuck main.optf
```
-O0 flag can be used to get less optimized Brainfuck code, which is more traceable. 
```
./optifuck main.optf -O0
```

## Executing Brainfuck code

There are  many  ways to execute  Brainfuck  code, for example  through  [online  compilers  in the browser](https://esolangpark.vercel.app/ide/brainfuck),  or  using interpreters such  as  [brainvuck](https://github.com/vlang/v/blob/master/examples/brainvuck.v) - an interpreter made by V developers. I  suggest my own  way  - to use a translator  from  Brainfuck  to  V,  which  I have made.  Thus, the program  will  work many times  faster  than  during  interpretation. The source file of it can be found in `additionary` folder. 
```
cd additinial && v bf2v
./bf2v /path/to/bfcode (-o flag to specify custom name of output file, -d flag will
include to final v file some debug information)
```
I plan to make integration between this translator and Optifuck, to produce more efficient v files

## Optifuck syntax

This is the very early version of Optifuck, so functional is insignificant now.

### Variables
There is a keyword `cell` which is used to allocated a bf cell as a variable. Cell value can be between 0 and 255(1 unsigned byte)
```
cell a = 15
cell b = a
```
### Operators
There are some primitive operators  which can be applied to cells
```
a += 20
//a = 35
a -= 3
//a = 32
a /= 8
//a = 4
```
 ### Printing
 There is print("") function which produces output
 ```
 print("Hello, world!")
 //Output: Hello, world!
 ```
 ### If
 For now, Optifuck only support checking a variable  for  positivity
 ```
 cell a = 10
 if(a) {
	print("a is positive!")
	a = 0
}
if(a) {
	print("still positive")
}
//Output: a is positive!
```

### Cycles
For now, Optifuck supports repeat() and while cycle
repeat:
```
cell a = 3
repeat(a) {
	a -= 1
}
repeat(5) {
	a += 4
}
//a is 20
```
while:
```
cell b = 6
while(b) {
	b -= 2
	print("$")
}
//Output: $$$
```

## Plans for this project
Learning Brainfuck and trying to use it seems interesting to me, i will continue adding new features to Optifuck.
Some of features i will implement in near future:

 - better if, and adding of else blocks
 - inputting numbers and chars
 - procedures
 - integration with my v translator
