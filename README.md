# zap
A lightweight register-based virtual machine written in Zig. Simple SSA parsing, compiling down to 64 bit bytecode, virtual machine houses 256 general purpose registers.

* ⚠️ Zig 0.15.2 required.

# Features
* Register based VM with 256 registers holding 32 bit signed integers.
* Simple SSA language.
* Single pass compiler.
* 64 bit packed instructions.

# Example

A simple program in Zap's language:
```zig
%0 = loadk 100
%1 = loadk 200
%2 = add %0, %1
print %2
halt
```

```
$ zig build run
126
```

AST Produced:
```
[0]: LOADK 0 [42]
[1]: LOADK 1 [84]
[2]: BINOP add 0 1 [3]
[3]: PRINT [3]
[4]: HALT
```

# Instruction Set

# zap

A lightweight register-based virtual machine written in Zig. Zap parses a simple SSA-style assembly language, compiles it to 64-bit bytecode, and executes it on a register machine with 256 general-purpose registers.

## Features

- Register-based VM with 256 `i32` registers
- Simple SSA-style assembly language
- Single-pass compiler (parser → codegen → bytecode)
- 64-bit packed instruction encoding
- Arithmetic: `add`, `sub`
- Built-in `print` and `halt` instructions

## Example

Write a program in zap's assembly language:

```
%0 = loadk 100
%1 = loadk 200
%2 = add %0, %1
print %2
halt
```

Compile and run it:

```
$ zig build run
300
```

The AST produced by the parser:

```
[0]: LOADK 0 [100]
[1]: LOADK 1 [200]
[2]: BINOP add 0 1 [2]
[3]: PRINT [2]
[4]: HALT
```

## Instruction Set

| Instruction         | Description                                  |
|---------------------|----------------------------------------------|
| `%d = loadk <imm>`  | Load immediate integer into register `%d`    |
| `%d = add %a, %b`   | Add registers `%a` and `%b`, store in `%d`   |
| `%d = sub %a, %b`   | Subtract `%b` from `%a`, store in `%d`       |
| `print %r`          | Print the value of register `%r`             |
| `halt`              | Stop execution                               |