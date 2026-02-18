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

| Instruction         | Description                                  |
|---------------------|----------------------------------------------|
| `%d = loadk <imm>`  | Load immediate integer into register `%d`    |
| `%d = add %a, %b`   | Add registers `%a` and `%b`, store in `%d`   |
| `%d = sub %a, %b`   | Subtract `%b` from `%a`, store in `%d`       |
| `print %r`          | Print the value of register `%r`             |
| `halt`              | Stop execution                               |