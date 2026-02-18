# zap
A lightweight register-based virtual machine written in Zig.

# Example
```zig
const bytecode = [_]u64{
    loadk(0, 42),
    loadk(1, 84),
    add(0, 1, 0),
};
```

```
[debug!] loaded constant 42 into register 0
[debug!] loaded constant 84 into register 1
[debug!] added register 0 and 1 into register 0
result = 126
```
